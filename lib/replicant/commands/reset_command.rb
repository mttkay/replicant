class ResetCommand < Command

  def description
    "clear current device and package"
  end

  def valid_args?
    args.blank?
  end

  def run
    @repl.default_device = nil
    @repl.default_package = nil
  end

end