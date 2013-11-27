require 'helper'

class ListCommandSpec < CommandSpecBase

  describe "listing commands" do
    it "prints a list of available commands" do
      command = silent ListCommand.new(@repl)
      command.execute
      command.output_capture.must_match /^!\w+/
    end
  end

end