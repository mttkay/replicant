require_relative '../styles'

class DeviceCommand < Command

  include Styles

  LOGFILE = "/tmp/replicant_device"

  @@threads = []

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

      Thread.abort_on_exception = true
      # kill any existing threads
      putsd "Found #{@@threads.size} zombie threads, killing..." unless @@threads.empty?
      @@threads.select! { |t| t.exit }

      i, o = redirect_device_logs

      @pid = find_pid(o)
      scan_pid!(o)

      transform_device_logs!(i, o)

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

  def find_pid(logfile)
    putsd "Scanning for PID..."
    processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
    pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
    if pid_line
      pid_line.split[1].strip.tap do |pid|
        log_state_change!(logfile, "#{@repl.default_package} (pid = #{pid})") if pid != @pid
        pid
      end
    else
      log_state_change!(logfile, "<all>") if @pid
      nil
    end
  end

  def scan_pid!(logfile)
    @@threads << Thread.new do 
      begin
        while @repl.default_package
          @pid = find_pid(logfile)
          sleep 2
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end

  def clear_logs!
    AdbCommand.new(@repl, "logcat -c", :silent => true).execute
  end

  def redirect_device_logs
    # create logging pipe if needed
    system "if ! [ -p #{LOGFILE} ]; then mkfifo #{LOGFILE}; fi"

    # redirect logcat to fifo pipe
    logcat = "logcat -v time"

    i = IO.popen(AdbCommand.new(@repl, logcat).command)
    o = open(LOGFILE, 'w+')

    [i, o]
  end

  def log_message!(o, message)
    o.puts "*" * Styles::CONSOLE_WIDTH
    o.puts " #{message}"
    o.puts "*" * Styles::CONSOLE_WIDTH
    o.flush
  end

  def log_state_change!(o, change)
    msg = "Detected change in device or target package\n"
    msg << "-" * Styles::CONSOLE_WIDTH
    msg << "\n   --> device  = #{@repl.default_device.name}"
    msg << "\n   --> process = #{change}"
    log_message!(o, msg)
  end

  def transform_device_logs!(i, o)
    log_segment = lambda do |segment, *styles|
      o.print(create_style(*styles))
      o.print(segment)
      o.print(end_style)
    end

    timestamp = /^\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{3}/
    process = /(\w){1}\/(.*)\(\s*([0-9]+)\):\s/

    @@threads << Thread.new do
      begin
        i.each_line do |line|
          ts_segment = line[timestamp]

          if ts_segment # found proper log line
            process_segment = process.match(line)
            pid = process_segment[3]

            if @repl.debug? && @pid && @pid != pid
              log_segment[" #{ts_segment} ", :black_fg]
              log_segment[" [muted]", :black_fg]
            else
              log_segment[" #{ts_segment} ", :white_bg, :bold]
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