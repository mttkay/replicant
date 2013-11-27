replicant - a repl for adb
==========================

`replicant` is an interactive shell (a [REPL][2]) for `adb`, the Android Debug Bridge.
It is partially based on Chris Wanstrath's excellent [repl][0] command line wrapper.

![repl](https://raw.github.com/mttkay/replicant/master/screenshots/01_repl.png)

Overview
-------
Working with the `adb` tool directly to target connected emulators and devices is
verbose and cumbersome. `replicant` simplifies this process in a number of ways:

- being a repl, you're now working with `adb` in interactive mode
- allows fixing devices and package IDs for subsequent `adb` commands
- auto-detection of target package by project folder inspection
- command history and tab-completion via `rlwrap` (see below)

### Example
In this example session, we start `replicant` from the folder of an existing Android
application. It detects the manifest file and sets a default package ID.
From here on we list the available commands, fix the device to the first listed
emulator, uninstall the app, then reset the session.

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     v0.0.1
                                dP oo                              dP
                                88                                 88
     88d888b. .d8888b. 88d888b. 88 dP .d8888b. .d8888b. 88d888b. d8888P
     88'  `88 88ooood8 88'  `88 88 88 88'  `"" 88'  `88 88'  `88   88
     88       88.  ... 88.  .88 88 88 88.  ... 88.  .88 88    88   88
     dP       `88888P' 88Y888P' dP dP `88888P' `88888P8 dP    dP   dP
                       88
                       dP                    (c) 2013 Matthias Kaeppler


     Type '!' to see a list of commands, '?' for environment info.
     Commands not starting in '!' are sent to adb verbatim.
     Use Ctrl-D (i.e. EOF) to exit.
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Setting default package to "com.soundcloud.android"
    >> !
    !clear                -- clear application data
    !device               -- set a default device to work with
    !devices              -- print a list of connected devices
    !logcat               -- access device logs
    !package              -- set a default package to work with
    !reset                -- clear current device and package
    !restart              -- restart ADB
    OK.
    >> !devices

    [0] Nexus 4                            | 005de387d71505d6
    [1] Genymotion Nexus 4 API 18 768x1280 | 192.168.56.101:5555

    OK.
    >> !device 0
    Setting default device to 005de387d71505d6 [Nexus 4]
    OK.
    >> uninstall
    Success
    OK.
    >> 

Install
-------
`replicant` requires Ruby 1.9 and a UNIX/Linux compatible shell such as `bash` or `zsh`.
For the best experience, I strongly recommend to install [rlwrap][1] to get
command history and tab-completion, although it's not a requirement. 
`replicant` integrates with `rlwrap` automatically;
it's sufficient for it to just be installed.

If all requirements are met, you can install `replicant` as a Ruby gem:

    $ gem install replicant-adb

Contributing
------------

[![Build Status](https://travis-ci.org/mttkay/replicant.png)](https://travis-ci.org/mttkay/replicant)

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

Copyright (c) 2013 Matthias Kaeppler. See LICENSE.txt for
further details.

[0]: https://github.com/defunkt/repl
[1]: http://utopia.knoware.nl/~hlub/rlwrap/
[2]: http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[3]: http://bundler.io/
