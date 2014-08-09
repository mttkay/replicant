class DevicesCommand < Command
  def description
    "print a list of connected devices"
  end

  def run
    adb = AdbCommand.new(@repl, "devices -l", :silent => true)
    device_lines = adb.execute.lines.to_a.reject do |line|
      line.strip.empty? || line.include?("daemon") || line.include?("List of devices")
    end

    device_ids = device_lines.map { |l| /([\S]+)\s+device/.match(l)[1] }
    device_products = device_lines.map { |l| /product:([\S]+)/.match(l).try(:[], 1) }

    device_names = device_lines.zip(device_ids).map do |l, id|
      /model:([\S]+)/.match(l).try(:[], 1) || detect_device_name(id)
    end

    devices = device_ids.zip(device_names, device_products).map do |id, name, product|
      Device.new(id, humanize_name(name, product))
    end

    output ""
    output devices_string(devices)
    output ""
    devices
  end

  private

  def detect_device_name(id)
    if id.start_with?("emulator-")
      "Android emulator"
    else
      "Unknown device"
    end
  end

  def humanize_name(name_string, product)
    if product == "vbox86p"
      "Genymotion " + name_string.gsub(/___[\d_]+___/, "_")
    else
      name_string
    end.gsub('_', ' ').squish
  end

  def devices_string(devices)
    device_string = if devices.any?
      padding = devices.map { |d| d.name.length }.max
      indices = (0..devices.length - 1).to_a
      indices.zip(devices).map { |i, d| "[#{i}] #{d.name}#{' ' * (padding - d.name.length)} | #{d.id}" }
    else
      "No devices found"
    end
  end
end