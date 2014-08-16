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
      transform_device_logs(*redirect_device_logs)
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

  def redirect_device_logs
    # kill any existing logging threads
    @@logging_threads.select! { |t| t.exit }

    # create logging pipe if needed
    system "if ! [ -p #{LOGFILE} ]; then mkfifo #{LOGFILE}; fi"

    # detect process ID by package name so we can filter by it
    @pid = if @repl.default_package
      processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
      pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
      pid_line.split[1].strip if pid_line
    end

    # clear existing logs
    AdbCommand.new(@repl, "logcat -c", :silent => true).execute

    # redirect logcat to fifo pipe
    logcat = "logcat -v time"

    i = IO.popen(AdbCommand.new(@repl, logcat).command)
    o = open(LOGFILE, 'w+')

    [i, o]
  end

  def transform_device_logs(i, o)
    o.puts "==================================================================="
    o.puts " Now logging: #{@repl.default_device.name}"
    o.puts " Process: #{@pid ? @repl.default_package : 'all'}"
    o.puts "==================================================================="
    o.flush

    log_segment = lambda do |segment, *styles|
      o.print(create_style(*styles))
      o.print(segment)
      o.print(end_style)
    end

    timestamp = /^\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{3}/
    process = /(\w){1}\/(.*)\(\s*([0-9]+)\):\s/

    Thread.abort_on_exception = true
    @@logging_threads << Thread.new do
      begin
        i.each_line do |line|
          ts_segment = line[timestamp]

          if ts_segment # found proper log line
            log_segment[" #{ts_segment} ", :white_bg, :bold]

            process_segment = process.match(line)
            pid = process_segment[3]

            if @pid && @pid != pid
              log_segment[" [muted]"]
            else
              # log level
              log_segment[" #{process_segment[1]} ", :black_bg, :yellow_fg, :bold]
              # log tag
              log_segment["#{process_segment[2]} ", :black_bg, :cyan_fg, :bold]
              # log remaining line
              remainder = [timestamp, process].reduce(line) { |l,r| l.gsub(r, '') }.strip
              log_segment[" #{remainder}", :white_fg]
            end
            o.write "\n"
            o.flush
          else # other log line, print as is
            o.puts(line)
          end
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end
end