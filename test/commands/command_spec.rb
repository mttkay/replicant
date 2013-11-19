require 'helper'

class CommandSpec < CommandSpecBase

  describe "command loading" do
    it "loads the ListCommand when command is '!'" do
      command = Command.load(@repl, "!")
      command.must_be_instance_of ListCommand
    end

    it "returns nil if !-command cannot be resolved" do
      Command.load(@repl, "!unknown").must_be_nil
    end

    it "loads the AdbCommand for commands not starting in '!'" do
      command = Command.load(@repl, "shell ps")
      command.must_be_instance_of AdbCommand
    end

    it "injects the arguments for loaded command objects" do
      command = Command.load(@repl, "shell ps")
      command.args.must_equal "shell ps"
    end
  end

  describe "the command interface" do
    before do
      class ::TestCommand < Command; end
      @command = TestCommand.new(@repl)
    end

    it "allows resolving the command name via type inspection" do
      @command.name.must_equal "!test"
    end

    it "triggers the run method when calling 'execute'" do
      @command.expects(:run).once
      @command.execute
    end

    it "does not trigger the run method when arguments are invalid" do
      @command.expects(:valid_args?).returns(false)
      @command.expects(:run).never
      @command.execute
    end
  end

  describe "command options" do
    before do
      class ::TestCommand < Command
        def run
          output "this is a test"
        end
      end
    end

    it "can silence console output" do
      command = TestCommand.new(@repl, [], :silent => true)
      command.expects(:puts).with("this is a test").never
      command.execute
    end
  end
end