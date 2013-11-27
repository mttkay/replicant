require 'helper'

class EnvCommandSpec < CommandSpecBase

  BLANK_ENV_OUTPUT = <<-OUT
Package: Not set
Device: Not set
  OUT

  ACTIVE_ENV_OUTPUT = <<-OUT
Package: com.myapp
Device: Emulator 1 (emulator-5554)
  OUT

  describe "with no device and no package fixed" do
    it "lists no devices and packages as selected" do
      command = EnvCommand.new(@repl)
      lambda { command.execute }.must_output(BLANK_ENV_OUTPUT)
    end
  end

  describe "with a device and package fixed" do
    it "lists no devices and packages as selected" do
      @repl.default_device = Device.new("emulator-5554", "Emulator 1")
      @repl.default_package = 'com.myapp'
      command = EnvCommand.new(@repl)
      lambda { command.execute }.must_output(ACTIVE_ENV_OUTPUT)
    end
  end
end