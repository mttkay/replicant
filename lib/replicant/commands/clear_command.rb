class ClearCommand < Command

  def description
    "clear application data"
  end

  # TODO: this is not a very good argument validator
  def valid_args?
    args.present? || @repl.default_package
  end

  def usage
    "#{name} [com.example.package|<empty>(when default package is set)]"
  end

  def run
    package = args.present? ? args : @repl.default_package
    # Clear app data - cache, SharedPreferences, Databases
    AdbCommand.new(@repl, "shell su -c \"rm -r /data/data/#{package}/*\"").execute
    # Force application stop to recreate shared preferences, databases with new launch
    AdbCommand.new(@repl, "shell am force-stop #{package}").execute
  end
end