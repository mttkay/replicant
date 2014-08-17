class Command
  attr_reader :shell_capture
  # capture system calls on all commands
  def `(cmd)
    @shell_capture = cmd
    nil
  end
  def system(cmd)
    @shell_capture = cmd
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