class ProcessMuncher

  def initialize(repl)
    @repl = repl
  end

  def process_table
    processes = AdbCommand.new(@repl, "shell ps", :silent => true).execute
    # Parses something like:
    # u0_a27    1333  123   517564 18668 ffffffff b75a59eb S com.android.musicfx
    processes.lines.map do |pid_line|
      columns = pid_line.split
      [columns[1], columns[-1]]
    end.to_h
  end

  def find_pid
    process_table.invert[@repl.default_package]
  end

  def scan_pid
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