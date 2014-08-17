require_relative 'styles'

class LogMuncher

  include Styles

  LOGFILE = "/tmp/replicant_device"
  TIMESTAMP_PATTERN = /^\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{3}/
  PROCESS_PATTERN = /(\w){1}\/(.*)\(\s*([0-9]+)\):\s/

  attr_accessor :current_pid

  def initialize(repl)
    @repl = repl
    @current_pid = nil
  end

  # Parses the device logs and reformats / recolors them
  def munch_logs
    logcat = "logcat -v time"

    i = IO.popen(AdbCommand.new(@repl, logcat).command)
    o = File.open(LOGFILE, 'wt')

    yield o if block_given?

    Thread.new do
      begin
        i.each_line do |line|
          transform_line(o, line)
          o.flush
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end

  private def transform_line(o, line)
    log_segment = lambda do |segment, *styles|
      o.print(create_style(*styles))
      o.print(segment)
      o.print(end_style)
    end

    ts_segment = line[TIMESTAMP_PATTERN]

    if ts_segment # found proper log line
      process_segment = PROCESS_PATTERN.match(line)
      pid = process_segment[3]

      if @current_pid.nil? || @current_pid == pid
        log_segment[" #{ts_segment} ", :white_bg, :bold]
        # log level
        log_segment[" #{process_segment[1]} ", :black_bg, :yellow_fg, :bold]
        # log tag
        log_segment["#{process_segment[2]} ", :black_bg, :cyan_fg, :bold]
        # log remaining line
        remainder = [TIMESTAMP_PATTERN, PROCESS_PATTERN].reduce(line) { |l,r| l.gsub(r, '') }.strip
        log_segment[" #{remainder}", :white_fg]

        o.write "\n"
      elsif @repl.debug?
        log_segment[" #{ts_segment} ", :black_fg]
        log_segment[" [muted]\n", :black_fg]
      end
    else # other log line, print as is
      o.puts(line)
    end
  end

end