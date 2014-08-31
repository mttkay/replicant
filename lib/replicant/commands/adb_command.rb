class AdbCommand < Command

  class Result
    attr_accessor :pid, :code, :output
  end

  def run
    Result.new.tap do |result|
      cmd = "#{command}"

      putsd cmd

      if interactive?
        system cmd
      else
        result.output = `#{cmd}`
        output result
      end
      result.pid  = $?.pid
      result.code = $?.exitstatus
      putsd "Command returned with exit status #{result.code}"
    end
  end

  def command
    adb = "adb"
    adb << " -s #{@repl.default_device.id}" if @repl.default_device
    adb << " #{args}"
    adb << " #{@repl.default_package}" if @repl.default_package && package_dependent?
    adb
  end

  private

  def interactive?
    args == "shell" || args.start_with?("logcat")
  end

  def package_dependent?
    ["uninstall"].include?(args)
  end
end