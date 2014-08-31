class Command
  attr_reader :shell_capture
  # capture system calls on all commands
  def `(cmd)
    capture_shell!(cmd)
  end
  def system(cmd)
    capture_shell!(cmd)
  end
  private def capture_shell!(cmd)
    @shell_capture = cmd
    # make sure $? is set
    Kernel::system("echo", "\\c")
    nil
  end  
end

class CommandSpecBase < MiniTest::Spec

  before do
    @repl = Replicant::REPL.new
  end

  def silent(command)
    def command.output(s)
      @output = s
    end
    def command.output_capture
      @output
    end
    command
  end
end