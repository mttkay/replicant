class ProcessMuncher

  def initialize(repl)
    @repl = repl
  end

  def find_pid
    processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
    pid_line = processes.lines.detect {|l| l.include?(@repl.default_package)}
    if pid_line
      pid_line.split[1].strip
    else
      nil
    end
  end

  def scan_pid!
    @last_pid = nil
    Thread.new do 
      begin
        while @repl.default_package
          pid = find_pid
          pid_changed = (pid && pid != @last_pid) || (pid.nil? && @last_pid)
          yield pid if block_given? && pid_changed
          @last_pid = pid
          sleep 2
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace.join("\n")
        raise e
      end
    end
  end

end