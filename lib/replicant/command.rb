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
      command_args = command_parts[1..-1]
      command_class = "#{command_name.capitalize}Command"
      begin
        clazz = Object.const_get(command_class)
        clazz.new(repl, command_args)
      rescue NameError => e
        nil
      end
    else
      # forward command to ADB
      AdbCommand.new(repl, Array(command_line.strip))
    end
  end

  attr_reader :args

  def initialize(repl, args = [])
    @repl = repl
    @args = Array(args)
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
      puts "Invalid arguments. Ex.: #{usage}"
    end
  end

  private

  def valid_args?
    true
  end

end

class AdbCommand < Command

  # the command line program
  ADB = 'adb'

  attr_accessor :silent

  def run
    begin
      cmd = "#{adb} #{args}"

      if interactive?
        system cmd
      else
        cmd << " #{@repl.default_package}" if @repl.default_package && package_dependent?
        output = `#{cmd}`
        puts cmd if @repl.debug?
        puts output unless silent
        output
      end
    end
  end

  def args
    @args.first
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
    adb = AdbCommand.new(@repl, "devices -l")
    adb.silent = true
    device_lines = adb.execute.lines.to_a[1..-1] # drop the first line

    device_regexp  = /([\S]+)\s+device(.*model:(\w+).*|.*)/
    device_matches = device_lines.map { |l| device_regexp.match(l) }.compact
    devices = device_matches.map do |m|
      device_id = m[1]
      device_name = m[3].gsub('_', ' ') rescue "unknown device"
      Device.new(device_id, device_name)
    end
    puts ""
    puts devices.map { |d| "#{d.id} #{' ' * (20 - d.id.length)}[#{d.name}]" } 
    puts ""
    devices
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
    args.length == 1 && /^\w+(\.\w+)*$/ =~ args.first
  end

  def run
    default_package = args.first
    puts "Setting default package to #{default_package.inspect}"
    @repl.default_package = default_package
  end
end

class DeviceCommand < Command
  def description
    "set a default device to work with"
  end

  def usage
    "#{name} [emulator-5554|emu1|<serial>|dev1|...]"
  end

  def valid_args?
    args.length == 1 && (devices.include?(args.first.strip) || emu_shortcut || dev_shortcut)
  end

  def run
    shortcut = detect_shortcut
    default_device = if shortcut
      # e.g. emu1 or dev2
      dev_number = shortcut.first[1].to_i
      shortcut.last[dev_number - 1]
    else
      args.first
    end

    if default_device
      puts "Setting default device to #{default_device.inspect}"
      @repl.default_device = default_device
    else
      puts "No such device"
    end
  end

  private

  def detect_shortcut
    [[emu_shortcut, emulators], [dev_shortcut, physical_devices]].find { |s| !s.first.nil? }
  end

  def emu_shortcut
    /^emu(\d)+/.match(args.first)
  end

  def dev_shortcut
    /^dev(\d)+/.match(args.first)
  end

  def devices
    @devices ||= DevicesCommand.new(@repl).execute
  end

  def emulators
    devices.find_all { |d| d.emulator? }
  end

  def physical_devices
    devices - emulators
  end

end

class ResetCommand < Command

  def description
    "clear current device and package"
  end

  def valid_args?
    args.empty?
  end

  def run
    @repl.default_device = nil
    @repl.default_package = nil
  end

end

class ListCommand < Command
  def valid_args?
    args.empty?
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
    puts command_list.join("\n")
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
    args.empty?
  end

  def run
    pid = if @repl.default_package
      shell_ps = AdbCommand.new(@repl, "shell ps")
      shell_ps.silent = true
      processes = shell_ps.execute
      pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
      pid_line.split[1].strip if pid_line
    end

    logcat = "logcat -v time"
    logcat << " | grep -E '\(\s*#{pid}\)'"
    AdbCommand.new(@repl, logcat).execute
  end

class ClearCommand < Command

  def description
    "clear application data"
  end

  def valid_args?
    args.empty?
  end

  def run
    # Clear app data - cache, SharedPreferences, Databases
    AdbCommand.new(@repl, "shell su -c \"rm -r /data/data/#{@repl.default_package}/*\"").execute
    # Force application stop to recreate shared preferences, databases with new launch
    AdbCommand.new(@repl, "shell am force-stop #{@repl.default_package}").execute
  end
end

end
