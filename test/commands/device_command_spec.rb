require 'helper'

class DeviceCommandSpec < CommandSpecBase

  describe "given a valid list of devices" do
    before do
      @device0 = Device.new("emulator-5554", "Emulator 1")
      @device1 = Device.new("emulator-5556", "Emulator 2")
      DevicesCommand.any_instance.stubs(:execute).returns([@device0, @device1])
    end

    it "can select a device by index" do
      silent(DeviceCommand.new(@repl, "0")).execute
      @repl.default_device.must_equal @device0
      silent(DeviceCommand.new(@repl, "1")).execute
      @repl.default_device.must_equal @device1
    end

    it "can select a device by device id" do
      silent(DeviceCommand.new(@repl, "emulator-5554")).execute
      @repl.default_device.must_equal @device0
      silent(DeviceCommand.new(@repl, "emulator-5556")).execute
      @repl.default_device.must_equal @device1
    end

    it "outputs an error message if selected device doesn't exist" do
      command = DeviceCommand.new(@repl, "emulator-bogus")
      lambda { command.execute }.must_output "No such device\n"
    end
  end

  describe "given an empty list of devices" do
    it "outputs an error message when selecting a device" do
      DevicesCommand.any_instance.stubs(:execute).returns([])
      command = DeviceCommand.new(@repl, "emulator-5554")
      lambda { command.execute }.must_output "No such device\n"
    end
  end

end