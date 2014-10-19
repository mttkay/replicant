require 'stringio'

class Command

  include Styles

  def self.inherited(subclass)
    @@subclasses ||= []
    @@subclasses << subclass
  end

  def self.all
    (@@subclasses - [AdbCommand, ListCommand, EnvCommand]).map do |clazz|
      clazz.new(nil)
    end
  end

  def self.load(repl, command_line)
    if command_line == '!'
      # load command that lists available commands
      ListCommand.new(repl)
    elsif command_line == '?'
      EnvCommand.new(repl)
    elsif command_line.start_with?('!')
      # load custom command
      command_parts = command_line[1..-1].split
      command_name = command_parts.first
      command_args = command_parts[1..-1].join(' ')
      command_class = "#{command_name.capitalize}Command"
      begin
        clazz = Object.const_get(command_class)
        clazz.new(repl, command_args)
      rescue NameError => e
        nil
      end
    else
      # forward command to ADB
      AdbCommand.new(repl, command_line.strip)
    end
  end

  attr_reader :args

  def initialize(repl, args = nil, options = {})
    @repl = repl
    @args = args.strip if args
    @options = options
  end

  def name
    "!#{self.class.name.gsub("Command", "").downcase}"
  end

  # subclasses override this to provide a description of their functionality
  def description
    "TODO: description missing"
  end

  # subclasses override this to provide a usage example
  def usage
  end

  def execute
    if valid_args?
      run
    else
      output "Invalid arguments. Ex.: #{usage}"
    end
  end

  private

  def valid_args?
    true
  end

  def output(message)
    @repl.output(message) unless @options[:silent]
  end

  def putsd(message)
    puts "[DEBUG] #{message}" if @repl.debug?
  end

end
