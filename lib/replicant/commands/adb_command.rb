class AdbCommand < Command

  # the command line program
  ADB = 'adb'

  def run
    begin
      cmd = "#{adb} #{args}"

      if require_subshell?
        system cmd
      else
        cmd << " #{@repl.default_package}" if @repl.default_package && package_dependent?
        output cmd if @repl.debug?
        result = `#{cmd}`
        output result
        result
      end
    end
  end

  private

  def adb
    adb = "#{ADB}"
    adb << " -s #{@repl.default_device.id}" if @repl.default_device
    adb
  end

  def require_subshell?
    args == "shell" || args.start_with?("logcat")
  end

  def package_dependent?
    ["uninstall"].include?(args)
  end
end