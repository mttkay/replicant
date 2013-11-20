require 'helper'

class PackageCommandSpec < CommandSpecBase

  describe "with valid arguments" do
    it "accepts a package with one element" do
      command = PackageCommand.new(@repl, "myapp")
      command.execute
      @repl.default_package.must_equal "myapp"
    end

    it "accepts a package with two elements" do
      command = PackageCommand.new(@repl, "com.myapp")
      command.execute
      @repl.default_package.must_equal "com.myapp"
    end
  end

  describe "with invalid arguments" do
    it "refuses a package not starting with alphanumeric characters" do
      command = PackageCommand.new(@repl, "%myapp")
      command.expects(:run).never
      command.execute
      @repl.default_package.must_be_nil
    end

    it "refuses a package containing non-alphanumeric characters" do
      command = PackageCommand.new(@repl, "myapp.some$thing")
      command.expects(:run).never
      command.execute
      @repl.default_package.must_be_nil
    end
  end
end