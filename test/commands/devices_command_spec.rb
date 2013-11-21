require 'helper'

ADB_NO_DEVICES = <<-OUTPUT
* daemon not running. starting it now on port 5037 *
* daemon started successfully *
List of devices attached

OUTPUT

ADB_DEVICES = <<-OUTPUT
* daemon not running. starting it now on port 5037 *
* daemon started successfully *
List of devices attached
192.168.56.101:5555    device product:vbox86p model:Nexus_4___4_3___API_18___768x1280 device:vbox86p
005de387d71505d6       device usb:1D110000 product:occam model:Nexus_4 device:mako
emulator-5554          device

OUTPUT

REPLICANT_DEVICES = <<-OUTPUT

[0] Genymotion Nexus 4 API 18 768x1280 | 192.168.56.101:5555
[1] Nexus 4                            | 005de387d71505d6
[2] Android emulator                   | emulator-5554

OUTPUT

class DevicesCommandSpec < CommandSpecBase

  describe "when no devices were found" do
    it "prints a message and exits" do
      AdbCommand.any_instance.expects(:execute).returns(ADB_NO_DEVICES)
      command = DevicesCommand.new(@repl)
      lambda { command.execute }.must_output("\nNo devices found\n\n")
    end
  end

  describe "when devices were found" do
    it "outputs a prettified, indexed list of devices" do
      AdbCommand.any_instance.expects(:execute).returns(ADB_DEVICES)
      command = DevicesCommand.new(@repl)
      lambda { command.execute }.must_output(REPLICANT_DEVICES)
    end
  end

end