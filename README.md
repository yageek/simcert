# simcert
simcert intends to be an usable alternative to [iostrust](https://github.com/yageek/iostrust)  helping you to automatically install http root certificates on the iOS simulators.

[![screencast](sim_cert.gif)]

## How does it work ?
It relies on the OSX Accessibility API and use some QuartCore Events to  perform some clicks.

# Installation
- Clone project and build the main project.
- Enable Accessibility API for `Terminal` or `iTerm2` if you launch from the terminal.
- Enable Accessibility API for `XCode` if you launch it from XCode.

# Usage
From command-line:

```
simcert -uuid <Simulator ID> -certificate <Path to certificate>
```
