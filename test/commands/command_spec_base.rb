class Command
  attr_reader :backtick_capture
  attr_reader :system_capture
  # capture system calls on all commands
  def `(cmd)
    @backtick_capture = cmd
    nil
  end
  def system(cmd)
    @system_capture = cmd
    nil
  end
end

class CommandSpecBase < MiniTest::Spec

  before do
    @repl = Replicant::REPL.new
  end

end