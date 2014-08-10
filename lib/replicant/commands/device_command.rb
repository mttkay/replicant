require_relative '../styles'

class DeviceCommand < Command

  include Styles

  LOGFILE = "/tmp/replicant_device"

  @@logging_threads = []

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
      @repl.default_device = default_device
      output "Default device set to #{default_device.name}"
      redirect_device_logs!
      output "Logs are available at #{LOGFILE}"
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

  def redirect_device_logs!
    # kill any existing logging threads
    @@logging_threads.select! { |t| t.exit }

    # detect process ID by package name so we can filter by it
    pid = if @repl.default_package
      processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
      pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
      pid_line.split[1].strip if pid_line
    end

    # create logging pipe if needed
    system "if ! [ -p #{LOGFILE} ]; then mkfifo #{LOGFILE}; fi"

    # redirect logcat to fifo pipe
    i = IO.popen(AdbCommand.new(@repl, "logcat -v time").command)
    o = open(LOGFILE, 'w+')

    # clear logcat
    AdbCommand.new(@repl, "logcat -c", :silent => true).execute

    o.puts "==================================================================="
    o.puts " Now logging: #{@repl.default_device.name}"
    o.puts "==================================================================="
    o.flush

    @@logging_threads << Thread.new do
      i.each_line do |line|
        # ts = line[/^\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{3}/]
        # o.print(create_style(:green_fg))
        # o.print(ts)
        # o.print(end_style)
        # o.print("\n")
        o.puts(line)
        o.flush
      end
    end
  end
end