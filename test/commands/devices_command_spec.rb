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

class DevicesCommandSpec < CommandSpecBase

  describe "when no devices were found" do
    before do
      AdbCommand.any_instance.expects(:execute).returns(ADB_NO_DEVICES)
    end

    it "returns an empty device list" do
      command = silent DevicesCommand.new(@repl)
      command.execute.must_equal []
    end

  end

  describe "when devices were found" do
    before do
      AdbCommand.any_instance.expects(:execute).returns(ADB_DEVICES)
    end

    it "returns the list of devices" do
      command = silent DevicesCommand.new(@repl)
      devices = command.execute
      devices.map { |d| d.id }.must_equal [
        "192.168.56.101:5555", "005de387d71505d6", "emulator-5554"
      ]
    end

  end

end