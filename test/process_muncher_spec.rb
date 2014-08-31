require 'helper'

class ProcessMuncherSpec < MiniTest::Spec

ADB_SHELL_PS = <<-OUTPUT
USER     PID   PPID  VSIZE  RSS     WCHAN    PC         NAME
root      1     0     716    480   c10b5805 0805a586 S /init
u0_a50    1247  123   562480 54296 ffffffff b75a59eb S com.soundcloud.android
u0_a27    1333  123   517564 18668 ffffffff b75a59eb S com.android.musicfx

OUTPUT

  describe "Given an adb process list containing the desired process" do
    
    before do
      AdbCommand.any_instance.stubs(:execute).returns(stub(:output => ADB_SHELL_PS))
      repl = stub(:default_package => "com.soundcloud.android")
      @muncher = ProcessMuncher.new(repl)
    end

    it "parses the process list into a table" do
      @muncher.process_table["1247"].must_equal "com.soundcloud.android"
      @muncher.process_table["1333"].must_equal "com.android.musicfx"
    end

    it "extracts the PID for the default package" do
      @muncher.find_pid.must_equal "1247"
    end

  end

  describe "Given an adb process list without the desired process" do
    
    before do
      AdbCommand.any_instance.stubs(:execute).returns(stub(:output => ADB_SHELL_PS))
      repl = stub(:default_package => "not in process list")
      @muncher = ProcessMuncher.new(repl)
    end

    it "returns nil for the default package PID" do
      @muncher.find_pid.must_be_nil
    end

  end

  describe "When no default package is set" do

    before do
      AdbCommand.any_instance.stubs(:execute).returns(stub(:output => ADB_SHELL_PS))
      repl = stub(:default_package => nil)
      @muncher = ProcessMuncher.new(repl)
    end

    it "returns nil for the default package PID" do
      @muncher.find_pid.must_be_nil
    end

  end
end