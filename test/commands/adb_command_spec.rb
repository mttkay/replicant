require 'helper'

class AdbCommandSpec < CommandSpecBase

  describe "a basic adb command" do
    before do
      @command = silent AdbCommand.new(@repl, "devices")
      @command.execute
    end

    it "sends a command to adb and captures the output" do
      @command.backtick_capture.must_equal "adb devices"
    end

    it "does not use Kernel#system" do
      @command.system_capture.must_be_nil
    end
  end

  describe "an interactive command" do
    before do
      @command = AdbCommand.new(@repl, "shell")
      @command.execute
    end

    it "is executed using a Kernel#system call" do
      @command.system_capture.must_equal "adb shell"
    end

    describe "when it's 'shell'" do
      it "is not treated as interactive when arguments are present" do
        command = AdbCommand.new(@repl, "shell ps")
        command.execute
        command.system_capture.must_be_nil
        command.backtick_capture.must_equal "adb shell ps"
      end
    end
  end

  describe "with a default package set" do
    before do
      @repl.stubs(:default_package).returns("com.myapp")
    end

    it "does not set the default package if command is not package dependent" do
      command = silent AdbCommand.new(@repl, "devices")
      command.execute
      command.backtick_capture.must_equal "adb devices"
    end

    it "adds the default package if command is package dependent" do
      command = silent AdbCommand.new(@repl, "uninstall")
      command.execute
      command.backtick_capture.must_equal "adb uninstall com.myapp"
    end
  end

end
