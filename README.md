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
     v1.0.0
                                dP oo                              dP
                                88                                 88
     88d888b. .d8888b. 88d888b. 88 dP .d8888b. .d8888b. 88d888b. d8888P
     88'  `88 88ooood8 88'  `88 88 88 88'  `"" 88'  `88 88'  `88   88
     88       88.  ... 88.  .88 88 88 88.  ... 88.  .88 88    88   88
     dP       `88888P' 88Y888P' dP dP `88888P' `88888P8 dP    dP   dP
                       88
                       dP                    (c) 2013 Matthias Kaeppler
    
    
     Type !list to see a list of commands.
     Commands not starting in '!' are sent to adb verbatim.
     Use Ctrl-D (i.e. EOF) to exit.
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Setting default package to "com.soundcloud.android"
    -- com.soundcloud.android, No device set
    >> !list
    !device               -- set a default device to work with
    !devices              -- print a list of connected devices
    !list                 -- print a list of available commands
    !package              -- set a default package to work with
    !reset                -- clear current device and package
    !restart              -- restart ADB
    OK.
    -- com.soundcloud.android, No device set
    >> !devices
    
    005de387d71505d6     [Nexus 4]
    emulator-5554        [Android SDK built for x86]
    
    OK.
    -- com.soundcloud.android, No device set
    >> !device emu1
    
    005de387d71505d6     [Nexus 4]
    emulator-5554        [Android SDK built for x86]
    
    Setting default device to emulator-5554 [Android SDK built for x86]
    OK.
    -- com.soundcloud.android, emulator-5554 [Android SDK built for x86]
    >> uninstall
    Success
    OK.
    -- com.soundcloud.android, emulator-5554 [Android SDK built for x86]
    >> !reset
    OK.
    -- No package set, No device set
    >> 

Install
-------
`replicant` requires Ruby 1.9 and a UNIX/Linux compatible shell such as `bash` or `zsh`.
For the best experience, I strongly recommend to install [rlwrap][1] to get
command history and tab-completion. `replicant` integrates with `rlwrap` automatically;
it's sufficient for it to just be installed.

To install, clone this repository then:

    $ cd replicant
    $ chmod 755 bin/replicant
    $ mkdir -p ~/bin/ && cd ~/bin
    $ ln -s <path/to/repo>/bin/replicant replicant

Make sure `~/bin` is in your `$PATH`.


License
------
```
Copyright (c) 2013 Matthias Käppler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

[0]: https://github.com/defunkt/repl
[1]: http://utopia.knoware.nl/~hlub/rlwrap/
[2]: http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
