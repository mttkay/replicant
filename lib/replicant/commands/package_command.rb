class PackageCommand < Command

  def description
    "set a default package to work with"
  end

  def usage
    "#{name} com.mydomain.mypackage"
  end

  def valid_args?
    args.present? && /^\w+(\.\w+)*$/ =~ args
  end

  def run
    output "Setting default package to #{args.inspect}"
    @repl.default_package = args
  end
end