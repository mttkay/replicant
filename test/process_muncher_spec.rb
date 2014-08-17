require 'helper'

class ProcessMuncherSpec < MiniTest::Spec

ADB_SHELL_PS_WITH_PID = <<-OUTPUT
USER     PID   PPID  VSIZE  RSS     WCHAN    PC         NAME
root      1     0     716    480   c10b5805 0805a586 S /init
u0_a50    1247  123   562480 54296 ffffffff b75a59eb S com.soundcloud.android
u0_a27    1333  123   517564 18668 ffffffff b75a59eb S com.android.musicfx

OUTPUT

ADB_SHELL_PS_WITHOUT_PID = <<-OUTPUT
USER     PID   PPID  VSIZE  RSS     WCHAN    PC         NAME
root      1     0     716    480   c10b5805 0805a586 S /init
u0_a27    1333  123   517564 18668 ffffffff b75a59eb S com.android.musicfx

OUTPUT

  describe "Given an adb process list containing the desired process" do
    
    before do
      AdbCommand.any_instance.stubs(:execute).returns(ADB_SHELL_PS_WITH_PID)
      repl = stub(:default_package => "com.soundcloud.android")
      @muncher = ProcessMuncher.new(repl)
    end

    it "extracts the PID" do
      pid = @muncher.find_pid
      pid.must_equal "1247"
    end

  end

  describe "Given an adb process list without the desired process" do
    
    before do
      AdbCommand.any_instance.stubs(:execute).returns(ADB_SHELL_PS_WITHOUT_PID)
      repl = stub(:default_package => "com.soundcloud.android")
      @muncher = ProcessMuncher.new(repl)
    end

    it "extracts the PID" do
      pid = @muncher.find_pid
      pid.must_be_nil
    end

  end

end