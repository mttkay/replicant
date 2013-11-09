require 'stringio'

class Command

  def self.inherited(subclass)
    @@subclasses ||= []
    @@subclasses << subclass unless subclass == AdbCommand
  end

  def self.commands
    @@subclasses.map do |clazz|
      clazz.new(nil).name
    end.sort
  end

  def self.load(repl, command_line)
    if command_line.start_with?('!')
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
      AdbCommand.new(repl, Array(command_line.strip))
    end
  end

  attr_reader :args

  def initialize(repl, args = [])
    @repl = repl
    @args = args
  end

  def name
    "!#{self.class.name.gsub("Command", "").downcase}"
  end

  def execute
    if valid_args?
      run
    else
      puts "Invalid arguments. Ex.: #{usage}"
    end
  end

  private

  def usage
    "#{name} #{sample_args}"
  end

  def sample_args
  end

  def valid_args?
    true
  end

end

class AdbCommand < Command

  def run
    begin
      cmd = "#{adb} #{args}"

      if interactive?
        system cmd
      else
        if package_dependent?
          cmd << " #{@repl.default_package}" if @repl.default_package
        end
        res = `#{cmd}`
        puts res unless res.empty?
        res
      end
    end
  end

  def args
    @args.first
  end

  private

  def adb
    adb = "#{REPL::ADB}"
    adb << " -s #{@repl.default_device}" if @repl.default_device
    adb
  end

  def interactive?
    ["logcat", "shell"].include?(args)
  end

  def package_dependent?
    ["uninstall"].include?(args)
  end
end

class DevicesCommand < Command
  def run
    adb_out = AdbCommand.new(@repl, ["devices"]).execute
    device_lines = adb_out.lines.find_all { |l| /device$/ =~ l }
    device_list = device_lines.map { |l| l.gsub("device", "").strip }
    puts device_list.inspect if @repl.debug?
    device_list
  end
end

class PackageCommand < Command

  def sample_args
    "com.mydomain.mypackage"
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
  def sample_args
    "emulator-5554"
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
    devices.find_all { |d| d.start_with?("emulator-") }
  end

  def physical_devices
    devices - emulators
  end

end

class ResetCommand < Command

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

  def run
    puts Command.commands.join("\n")
  end
end

class RestartCommand < Command
  def run
    # Faster than kill-server, and also catches ADB instances launched by
    # IntelliJ. Moreover, start-server after kill-server sometimes makes the
    # server fail to start up unless you sleep for a second or so
    `killall adb`
    AdbCommand.new(@repl, ["start-server"]).execute
  end
end

