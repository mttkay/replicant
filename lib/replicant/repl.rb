require 'find'
require 'rexml/document'

module Replicant
  class REPL

    include Styles

    # for auto-complete via rlwrap; should probably go in Rakefile at some point
    ADB_COMMANDS = %w(devices connect disconnect push pull sync shell emu logcat
      forward jdwp install uninstall bugreport backup restore help version
      wait-for-device start-server kill-server get-state get-serialno get-devpath
      status-window remount reboot reboot-bootloader root usb tcpip ppp)

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

      # try to detect a default package to work with from an AndroidManifest
      # file somewhere close by
      if manifest_path = detect_android_manifest_path
        app_package = get_package_from_manifest(manifest_path)
        PackageCommand.new(self, [app_package]).execute
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
      logo = <<-logo
                            dP oo                              dP
                            88                                 88
 88d888b. .d8888b. 88d888b. 88 dP .d8888b. .d8888b. 88d888b. d8888P
 88'  `88 88ooood8 88'  `88 88 88 88'  `"" 88'  `88 88'  `88   88
 88       88.  ... 88.  .88 88 88 88.  ... 88.  .88 88    88   88
 dP       `88888P' 88Y888P' dP dP `88888P' `88888P8 dP    dP   dP
                   88
                   dP                    (c) 2013 Matthias Kaeppler
      logo
      puts style + ("~" * 70)
      puts " v" + Replicant::VERSION
      puts span(logo, :green_fg) { style }
      puts ""
      puts " Type #{span('!list', :green_fg) { style }} to see a list of commands."
      puts " Commands that do not start in '!' are sent to adb verbatim."
      puts ("~" * 70) + unstyled
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

    def setup_rlwrap
      if !ENV['__REPL_WRAPPED'] && system("which rlwrap > /dev/null 2> /dev/null")
        ENV['__REPL_WRAPPED'] = '0'

        # set up auto-completion commands
        completion_file = File.expand_path('~/.adb_completion')
        File.open(completion_file, 'w') { |file| file.write(ADB_COMMANDS.join(' ')) }

        # set up command history
        if File.exists?(history_dir = File.expand_path(ENV['REPL_HISTORY_DIR'] || "~/"))
          history_file = "#{history_dir}/.adb_history"
        end

        rlargs = ""
        rlargs << " --break-chars=" # we don't want to break any of the commands
        rlargs << " -f #{completion_file}" if completion_file
        rlargs << " -H #{history_file}" if history_file

        exec "rlwrap #{rlargs} #$0 #{ARGV.join(' ')}"
      end
    end

    # best effort function to detect the manifest path.
    # checks for well known locations and falls back to a recursive search with
    # a maximum depth of 2 directory levels
    def detect_android_manifest_path
      manifest_file = 'AndroidManifest.xml'
      known_locations = %W(./#{manifest_file} ./src/main/#{manifest_file})
      known_locations.find {|loc| File.exist?(loc)} || begin
        Find.find('.') do |path|
          Find.prune if path.start_with?('./.') || path.split('/').size > 3
          return path if path.include?(manifest_file)
        end
      end
    end

    def get_package_from_manifest(manifest_path)
      manifest = REXML::Document.new(File.new(manifest_path))
      manifest.root.attributes['package']
    end  
  end
end