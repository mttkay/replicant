class DeviceCommand < Command

  LOGFILE = "/tmp/replicant_device"

  @@threads = []

  def initialize(repl, args = nil, options = {})
    super
    @process_muncher = ProcessMuncher.new(@repl)
  end

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
    default_device = if index? && (1..devices.size).include?(args.to_i)
      # user selected by index
      devices[args.to_i - 1]
    else
      # user selected by device ID
      devices.detect { |d| d.id == args }
    end

    if default_device
      @repl.default_device = default_device
      output "Default device set to #{default_device.name}"

      # kill any existing threads
      putsd "Found #{@@threads.size} zombie threads, killing..." unless @@threads.empty?
      @@threads.select! { |t| t.exit }

      i, o = redirect_device_logs

      @@threads << @process_muncher.scan_pid! do |new_pid|
        @current_pid = new_pid
        if new_pid
          log_state_change!(o, "#{@repl.default_package} (pid = #{new_pid})")
        else
          log_state_change!(o, "<all>")
        end
      end

      transform_device_logs!(i, o)

      output "Logs are available at #{LOGFILE}"
    else
      output "No such device"
    end

    default_device
  end

  private

  def index?
    /^\d+$/ =~ args
  end

  def devices
    @devices ||= DevicesCommand.new(@repl, nil, :silent => true).execute
  end

  def clear_logs!
    AdbCommand.new(@repl, "logcat -c", :silent => true).execute
  end

  def redirect_device_logs
    # redirect logcat to fifo pipe
    logcat = "logcat -v time"

    i = IO.popen(AdbCommand.new(@repl, logcat).command)
    o = File.open(LOGFILE, 'wt')

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

            if @current_pid.nil? || @current_pid == pid
              log_segment[" #{ts_segment} ", :white_bg, :bold]
              # log level
              log_segment[" #{process_segment[1]} ", :black_bg, :yellow_fg, :bold]
              # log tag
              log_segment["#{process_segment[2]} ", :black_bg, :cyan_fg, :bold]
              # log remaining line
              remainder = [timestamp, process].reduce(line) { |l,r| l.gsub(r, '') }.strip
              log_segment[" #{remainder}", :white_fg]

              o.write "\n"
            elsif @repl.debug?
              log_segment[" #{ts_segment} ", :black_fg]
              log_segment[" [muted]\n", :black_fg]
            end
          else # other log line, print as is
            o.puts(line)
          end
          o.flush
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end
end