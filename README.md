# SimCert
SimCert intends to be an usable alternative to [iostrust](https://github.com/yageek/iostrust)  helping you to automatically install http root certificates on the iOS simulators.

[![screencast](sim_cert.gif)]

## How does it works ?
It relies on the OSX Accessibility API and use some QuartCore Events to  perform some clicks.

# Installation
- Clone project and build the main project.
- Enable Accessibility API to `Terminal` or `iTerm2`.

# Usage
From command-line:

```
/Applications/SimCert.app/Contents/MacOS/SimCert -uuid <Simulator ID> -certificate <Path to certificate>
```
