require 'stringio'

class Command

  def self.inherited(subclass)
    @@subclasses ||= []
    @@subclasses << subclass
  end

  def self.load(repl, command_line)
    if command_line == '!'
      # load command that lists available commands
      ListCommand.new(repl)
    elsif command_line.start_with?('!')
      # load custom command
      command_parts = command_line[1..-1].split
      command_name = command_parts.first
      command_args = command_parts[1..-1].join(' ')
      command_class = "#{command_name.capitalize}Command"
      begin
        clazz = Object.const_get(command_class)
        clazz.new(repl, command_args)
      rescue NameError => e
        nil
      end
    else
      # forward command to ADB
      AdbCommand.new(repl, command_line.strip)
    end
  end

  attr_reader :args

  def initialize(repl, args = nil, options = {})
    @repl = repl
    @args = args.strip if args
    @options = options
  end

  def name
    "!#{self.class.name.gsub("Command", "").downcase}"
  end

  # subclasses override this to provide a description of their functionality
  def description
    "TODO: description missing"
  end

  # subclasses override this to provide a usage example
  def usage
  end

  def execute
    if valid_args?
      run
    else
      output "Invalid arguments. Ex.: #{usage}"
    end
  end

  private

  def valid_args?
    true
  end

  def output(message)
    puts message unless @options[:silent]
  end

end

class AdbCommand < Command

  # the command line program
  ADB = 'adb'

  def run
    begin
      cmd = "#{adb} #{args}"

      if interactive?
        system cmd
      else
        cmd << " #{@repl.default_package}" if @repl.default_package && package_dependent?
        output cmd if @repl.debug?
        result = `#{cmd}`
        output result
        result
      end
    end
  end

  private

  def adb
    adb = "#{ADB}"
    adb << " -s #{@repl.default_device.id}" if @repl.default_device
    adb
  end

  def interactive?
    args == "shell" || args.start_with?("logcat")
  end

  def package_dependent?
    ["uninstall"].include?(args)
  end
end

class DevicesCommand < Command
  def description
    "print a list of connected devices"
  end

  def run
    adb = AdbCommand.new(@repl, "devices -l", :silent => true)
    device_lines = adb.execute.lines.to_a.reject do |line|
      line.strip.empty? || line.include?("daemon") || line.include?("List of devices")
    end

    device_ids = device_lines.map { |l| /([\S]+)\s+device/.match(l)[1] }
    device_products = device_lines.map { |l| /product:([\S]+)/.match(l).try(:[], 1) }

    device_names = device_lines.zip(device_ids).map do |l, id|
      /model:([\S]+)/.match(l).try(:[], 1) || detect_device_name(id)
    end

    devices = device_ids.zip(device_names, device_products).map do |id, name, product|
      Device.new(id, humanize_name(name, product))
    end

    output ""
    output devices_string(devices)
    output ""
    devices
  end

  private

  def detect_device_name(id)
    if id.start_with?("emulator-")
      "Android emulator"
    else
      "Unknown device"
    end
  end

  def humanize_name(name_string, product)
    if product == "vbox86p"
      "Genymotion " + name_string.gsub(/___[\d_]+___/, "_")
    else
      name_string
    end.gsub('_', ' ').squish
  end

  def devices_string(devices)
    device_string = if devices.any?
      padding = devices.map { |d| d.name.length }.max
      indices = (0..devices.length - 1).to_a
      indices.zip(devices).map { |i, d| "[#{i}] #{d.name}#{' ' * (padding - d.name.length)} | #{d.id}" }
    else
      "No devices found"
    end
  end
end

class PackageCommand < Command

  def description
    "set a default package to work with"
  end

  def usage
    "#{name} com.mydomain.mypackage"
  end

  def valid_args?
    args.present? && /^\w+(\.\w+)*$/ =~ args
  end

  def run
    output "Setting default package to #{args.inspect}"
    @repl.default_package = args
  end
end

class DeviceCommand < Command
  def description
    "set a default device to work with"
  end

  def usage
    "#{name} [<index>|<device_id>]"
  end

  def valid_args?
    args.present? && /\S+/ =~ args
  end

  def run
    default_device = if index?
      # user selected by index
      devices[args.to_i]
    else
      # user selected by device ID
      devices.detect { |d| d.id == args }
    end

    if default_device
      output "Setting default device to #{default_device.inspect}"
      @repl.default_device = default_device
    else
      output "No such device"
    end
  end

  private

  def index?
    /^\d+$/ =~ args
  end

  def devices
    @devices ||= DevicesCommand.new(@repl, nil, :silent => true).execute
  end

end

class ResetCommand < Command

  def description
    "clear current device and package"
  end

  def valid_args?
    args.blank?
  end

  def run
    @repl.default_device = nil
    @repl.default_package = nil
  end

end

class ListCommand < Command
  def valid_args?
    args.blank?
  end

  def description
    "print a list of available commands"
  end

  def run
    command_list = commands.sort_by {|c| c.name}.map do |command|
      padding = 20 - command.name.length
      desc = "#{command.name} #{' ' * padding} -- #{command.description}"
      desc << " (e.g. #{command.usage})" if command.usage
      desc
    end
    output command_list.join("\n")
  end

  private

  def commands
    (@@subclasses - [AdbCommand, ListCommand]).map do |clazz|
      clazz.new(nil)
    end
  end

end

class RestartCommand < Command
  def description
    "restart ADB"
  end

  def run
    # Faster than kill-server, and also catches ADB instances launched by
    # IntelliJ. Moreover, start-server after kill-server sometimes makes the
    # server fail to start up unless you sleep for a second or so
    `killall adb`
    AdbCommand.new(@repl, "start-server").execute
  end
end

class LogcatCommand < Command

  def description
    "access device logs"
  end

  def valid_args?
    args.blank?
  end

  def run
    pid = if @repl.default_package
      processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
      pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
      pid_line.split[1].strip if pid_line
    end

    logcat = "logcat -v time"
    logcat << " | grep -E '\(\s*#{pid}\)'"
    AdbCommand.new(@repl, logcat).execute
  end
end

class ClearCommand < Command

  def description
    "clear application data"
  end

  # TODO: this is not a very good argument validator
  def valid_args?
    args.present? || @repl.default_package
  end

  def usage
    "#{name} [com.example.package|<empty>(when default package is set)]"
  end

  def run
    package = args.present? ? args : @repl.default_package
    # Clear app data - cache, SharedPreferences, Databases
    AdbCommand.new(@repl, "shell su -c \"rm -r /data/data/#{package}/*\"").execute
    # Force application stop to recreate shared preferences, databases with new launch
    AdbCommand.new(@repl, "shell am force-stop #{package}").execute
  end
end