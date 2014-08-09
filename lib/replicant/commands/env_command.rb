class EnvCommand < Command

  def valid_args?
    args.blank?
  end

  def run
    env = "Package: #{@repl.default_package || 'Not set'}\n"
    env << "Device: "
    device = @repl.default_device
    env << if device
      "#{device.name} (#{device.id})"
    else
      'Not set'
    end
    output env
  end
end
