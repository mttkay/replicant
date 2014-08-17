class DeviceCommand < Command

  @@threads = []

  def initialize(repl, args = nil, options = {})
    super
    @process_muncher = ProcessMuncher.new(repl)
    @log_muncher = LogMuncher.new(repl)
  end

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
    default_device = if index? && (1..devices.size).include?(args.to_i)
      # user selected by index
      devices[args.to_i - 1]
    else
      # user selected by device ID
      devices.detect { |d| d.id == args }
    end

    if default_device
      @repl.default_device = default_device
      output "Default device set to #{default_device.name}"

      # kill any existing threads
      putsd "Found #{@@threads.size} zombie threads, killing..." unless @@threads.empty?
      @@threads.select! { |t| t.exit }
      
      @@threads << @log_muncher.munch_logs do |logfile|
        observe_pid_changes(logfile)
      end

      output "Logs are available at #{LogMuncher::LOGFILE}"
    else
      output "No such device"
    end

    default_device
  end

  private

  def index?
    /^\d+$/ =~ args
  end

  def devices
    @devices ||= DevicesCommand.new(@repl, nil, :silent => true).execute
  end

  def observe_pid_changes(logfile)
    @@threads << @process_muncher.scan_pid do |new_pid|
      @log_muncher.current_pid = new_pid
      if new_pid
        log_state_change!(logfile, "#{@repl.default_package} (pid = #{new_pid})")
      else
        log_state_change!(logfile, "<all>")
      end
    end    
  end

  def log_message!(o, message)
    o.puts "*" * Styles::CONSOLE_WIDTH
    o.puts " #{message}"
    o.puts "*" * Styles::CONSOLE_WIDTH
    o.flush
  end

  def log_state_change!(o, change)
    msg = "Detected change in device or target package\n"
    msg << "-" * Styles::CONSOLE_WIDTH
    msg << "\n   --> device  = #{@repl.default_device.name}"
    msg << "\n   --> process = #{change}"
    log_message!(o, msg)
  end
end