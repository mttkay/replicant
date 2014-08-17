require 'helper'

class DeviceCommandSpec < CommandSpecBase

  describe "given a valid list of devices" do
    before do
      @device1 = Device.new("1", "emulator-5554", "Emulator 1")
      @device2 = Device.new("2", "emulator-5556", "Emulator 2")
      DevicesCommand.any_instance.stubs(:execute).returns([@device1, @device2])
    end

    it "can select a device by index" do
      device = silent(DeviceCommand.new(@repl, "1")).execute
      device.must_equal @device1
      device = silent(DeviceCommand.new(@repl, "2")).execute
      device.must_equal @device2
    end

    it "updates the repl with the selected device" do
      device = silent(DeviceCommand.new(@repl, "1")).execute
      @repl.default_device.must_equal @device1
    end

    it "can select a device by device id" do
      device = silent(DeviceCommand.new(@repl, "emulator-5554")).execute
      device.must_equal @device1
    end

    it "does not return or update anything if selected device doesn't exist" do
      device = silent(DeviceCommand.new(@repl, "100")).execute
      device.must_be_nil
      @repl.default_device.must_be_nil
    end
  end

  describe "given an empty list of devices" do
    before do
      DevicesCommand.any_instance.stubs(:execute).returns([])
    end

    it "does not return or update anything if selected device doesn't exist" do
      device = silent(DeviceCommand.new(@repl, "emulator-bogus")).execute
      device.must_be_nil
      @repl.default_device.must_be_nil
    end
  end

end