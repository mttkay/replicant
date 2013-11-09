REPLicant -- repl for ADB
====================================

`replicant` is an interactive shell for ADB, the Android Debug Bridge,
originally based on @defunkt's excellent [repl][0]
command line wrapper.

Usage:

    $ replicant
    adb >> !package com.myapp
    Setting default package to "com.myapp"
    [com.myapp] adb >> !device emulator-5554
    Setting default device to "emulator-5554"
    [com.myapp] adb@emulator-5554 >> uninstall
    Success!
    [com.myapp] adb@emulator-5554 >> shell
    # ...
    [com.myapp] adb@emulator-5554 >> !reset
    adb >> ...
    .. etc ..

If you have [rlwrap][1] installed you'll automatically get the full
benefits of readline: history, reverse searches, etc.

e.g. `brew install rlwrap`

Install
-------

### Standalone

`replicant` is easily installed as a standalone script:

    export REPLICANT_BIN=~/bin/replicant
    curl -s https://raw.github.com/mttkay/replicant/latest/bin/replicant > $REPLICANT_BIN
    chmod 755 $REPLICANT_BIN

Change `$REPLICANT_BIN` to your desired location, just make
sure it's in your `$PATH`.

### RubyGems

Currently broken. Working on it.

`replicant` can also be installed as a RubyGem:

    $ gem install replicant


License
------
```
Copyright (c) 2009-2013 Chris Wanstrath, Matthias Käppler

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
