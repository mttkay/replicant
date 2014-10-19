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
          log_line(o, line)
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end

  private def log_line(o, line)
    transform_line(line).each do |seg|
      text = seg.first
      styles = seg.last
      o.print(create_style(*styles))
      o.print(text)
      o.print(end_style)
    end
    o.flush
  end

  private def transform_line(line)
    segments = []
    
    timestamp = line[TIMESTAMP_PATTERN]

    if timestamp # found proper log line
      process = PROCESS_PATTERN.match(line)
      pid = process[3]

      if @current_pid.nil? || @current_pid == pid
        segments << [" #{timestamp} ", [:white_bg, :bold]]
        # log level
        level = process[1]
        level_fg = case level
        when "D" then :yellow_fg
        when "E" then :red_fg
        else :white_fg
        end
        segments << [" #{level} ", [:black_bg, :bold] << level_fg]
        # log tag
        tag = process[2].strip
        segments << ["#{tag} ", [:black_bg, :cyan_fg, :bold]]
        # log remaining line
        remainder = [TIMESTAMP_PATTERN, PROCESS_PATTERN].reduce(line) { |l,r| l.gsub(r, '') }.strip
        segments << [" #{remainder}\n", [:white_fg]]

      elsif @repl.debug?
        segments << [" #{timestamp} ", [:black_fg]]
        segments << [" [muted]\n", [:black_fg]]
      end
    end
    segments
  end

end