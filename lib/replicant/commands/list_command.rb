class ListCommand < Command
  def valid_args?
    args.blank?
  end

  def description
    "print a list of available commands"
  end

  def run
    command_list = Command.all.sort_by {|c| c.name}.map do |command|
      padding = 20 - command.name.length
      desc = "#{command.name} #{' ' * padding} -- #{command.description}"
      desc
    end
    output command_list.join("\n")
  end
end