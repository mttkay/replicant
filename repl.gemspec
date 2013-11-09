$LOAD_PATH.unshift 'lib'
require "replicant/version"

Gem::Specification.new do |s|
  s.name              = "replicant"
  s.version           = Replicant::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A REPL for the Android Debug Bridge"
  s.homepage          = "http://github.com/mttkay/replicant"
  s.email             = "m.kaeppler@gmail.com"
  s.authors           = [ "Matthias Käppler" ]
  s.has_rdoc          = false

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("bin/**/*")

  s.executables       = %w( replicant )
  s.description       = <<desc
REPLicant is an interactive shell for ADB, the Android Debug Bridge,
originally based on @defunkt's excellent repl command line wrapper.
desc
end
