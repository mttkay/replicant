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
  # re-route puts to not clutter test output
  def puts(s); end
end

class CommandSpecBase < MiniTest::Spec

  before do
    @repl = Replicant::REPL.new
  end

end