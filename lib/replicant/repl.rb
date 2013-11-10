class REPL

  include Styles

  ADB = 'adb'

  attr_accessor :default_package
  attr_accessor :default_device

  def initialize
  end

  def run
    # must be the first thing to execute, since it wraps the script
    setup_rlwrap

    show_greeting
    if ARGV.any? { |arg| %w( -h --help -help help ).include?(arg) }
      show_help
    end

    loop do
      command_loop
    end
  end

  def command_loop
    print prompt

    begin
      command_line = $stdin.gets.chomp
    rescue NoMethodError, Interrupt
      exit
    end

    return if command_line.strip.empty?

    command = Command.load(self, command_line)
    if command
      command.execute
      puts span("OK.", :white_fg, :bold) { unstyled }
    else
      puts "No such command"
    end

    warn "Use Ctrl-D (i.e. EOF) to exit" if command_line =~ /^(exit|quit)$/
  end

  def debug?
    ARGV.include?('--debug')
  end

  private

  def prompt
    prompt = ENV['REPL_PROMPT'] || begin
      package = @default_package || "No package set"
      device  = @default_device || "No device set"
      puts "#{unstyled}-- #{package}, #{device}"
      span('>> ', :white_fg, :bold) { styled(:green_fg) }
    end.lstrip
  end

  def show_greeting
    style = styled(:white_fg, :black_bg, :bold)
    puts style
    puts "~" * 75
    puts " Welcome to #{span('REPLicant', :green_fg) { style }}."
    puts ""
    puts " Type !list to obtain the list of commands."
    puts " Commands that do not start in '!' are sent to adb verbatim."
    puts "~" * 75
    puts unstyled
  end

  def show_help
    puts <<-help
  Usage: replicant [options]

  Options:
    --help    Display this message
    --debug   Display debug info

  Bug reports, suggestions, updates:
  http://github.com/mttkay/replicant/issues
  help
    exit
  end

  def setup_completion
    if File.exists?(completion_dir)
      set_completion_file!
    end
  end

  def completion_dir
    dir = ENV['REPL_COMPLETION_DIR'] || "~/.repl"
    File.expand_path(dir)
  end

  def set_completion_file!
    script = ARGV.detect { |a| a !~ /^-/ }
    if script
      @cfile = Dir[completion_dir + '/' + File.basename(script)].first
      @cfile = nil if @cfile && !File.exists?(@cfile)
    end
  end

  def setup_history
    history_dir = ENV['REPL_HISTORY_DIR'] || "~/"
    if File.exists?(hdir = File.expand_path(history_dir))
      set_history_file!(hdir)
    end
  end

  def set_history_file!(dir)
    if script = ARGV.detect { |a| a !~ /^-/ }
      script = File.basename(script)
      @hfile = "#{dir}/.#{script}_history"
    end
  end

  def setup_rlwrap
    setup_completion
    setup_history
    if !ENV['__REPL_WRAPPED'] && system("which rlwrap > /dev/null 2> /dev/null")
      ENV['__REPL_WRAPPED'] = '0'

      rlargs = ""
      rlargs << " -f #{@cfile}" if @cfile
      rlargs << " -H #{@hfile}" if @hfile

      exec "rlwrap #{rlargs} #$0 #{ARGV.join(' ')}"
    end

    if debug?
      print 'rlwrap ' if ENV['__REPL_WRAPPED']
      print "-f #{@cfile} " if @cfile
      print "-H #{@hfile} " if @hfile
      puts ADB.inspect
    end
  end  
end