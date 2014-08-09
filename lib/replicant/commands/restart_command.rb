class RestartCommand < Command
  def description
    "restart ADB"
  end

  def run
    # Faster than kill-server, and also catches ADB instances launched by
    # IntelliJ. Moreover, start-server after kill-server sometimes makes the
    # server fail to start up unless you sleep for a second or so
    `killall adb`
    AdbCommand.new(@repl, "start-server").execute
  end
end