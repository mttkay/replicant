class LogcatCommand < Command

  LOGFILE = "device_logs"

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

    system "rm -f #{LOGFILE} && mkfifo #{LOGFILE}"

    logcat = "logcat -v time | egrep --line-buffered "
    logcat << if pid then "'\(\s*#{pid}\)'" else "'.*'" end
    logcat << " >> #{LOGFILE} &"
    AdbCommand.new(@repl, logcat).execute
  end
end