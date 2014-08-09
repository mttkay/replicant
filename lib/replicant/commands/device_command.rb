class DeviceCommand < Command
  def description
    "set a default device to work with"
  end

  def usage
    "#{name} [<index>|<device_id>]"
  end

  def valid_args?
    args.present? && /\S+/ =~ args
  end

  def run
    default_device = if index?
      # user selected by index
      devices[args.to_i]
    else
      # user selected by device ID
      devices.detect { |d| d.id == args }
    end

    if default_device
      output "Setting default device to #{default_device.inspect}"
      @repl.default_device = default_device
    else
      output "No such device"
    end
  end

  private

  def index?
    /^\d+$/ =~ args
  end

  def devices
    @devices ||= DevicesCommand.new(@repl, nil, :silent => true).execute
  end

end