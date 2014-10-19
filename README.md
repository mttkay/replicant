replicant - a repl for adb
==========================
[![Gem Version](https://badge.fury.io/rb/replicant-adb.png)](http://badge.fury.io/rb/replicant-adb)
[![Build Status](https://travis-ci.org/mttkay/replicant.png)](https://travis-ci.org/mttkay/replicant)

`replicant` is an interactive shell (a [REPL][2]) for `adb`, the Android Debug Bridge.
It was originally based on Chris Wanstrath's excellent [repl][0] command line wrapper.

![repl](https://raw.github.com/mttkay/replicant/master/assets/replicant_anim.gif)

Overview
-------
Working with the `adb` tool directly to target connected emulators and devices is
verbose and cumbersome. `replicant` simplifies this process in a number of ways:

- allows working with `adb` in interactive mode
- allows fixing devices and package IDs for subsequent `adb` commands
- auto-detection of target package by project folder inspection
- command history and tab-completion via `rlwrap` (see below)
- smart log capturing and pretty printing based on selected device and package

Install
-------
`replicant` requires Ruby 1.9 or newer and a UNIX/Linux compatible shell such as `bash` or `zsh`.
For the best experience, I strongly recommend to install [rlwrap][1] to get
command history and tab-completion, although it's not a requirement. 
`replicant` integrates with `rlwrap` automatically;
it's sufficient for it to just be installed.

If all requirements are met, you can install `replicant` as a Ruby gem:

    $ gem install replicant-adb

Contributing
------------

Please hack on replicant and make it better and more feature complete!
Here's a general list of guidelines you should follow:

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature branch to implement your bugfix or idea.
* Write an executable spec. See existing specs in the test/ folder for examples.
* Commit and push until you are happy with your contribution.

After checking out the project, change into the project dir and do

    $ bundle install

to make sure all dependencies are installed. After making local changes, you can
install locally using

    $ rake install

And don't forget to regularly

    $ rake test


Copyright
---------

Copyright (c) 2013-2014 Matthias Kaeppler. See LICENSE.txt for
further details.

[0]: https://github.com/defunkt/repl
[1]: http://utopia.knoware.nl/~hlub/rlwrap/
[2]: http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[3]: http://bundler.io/
