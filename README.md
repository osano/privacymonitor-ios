# Privacy Monitor - iOS Client

[![Privacy Monitor by Osano][logo]][privacymonitor]

[![MIT License][li]][ll]
[![Platform][pi]][pl]

[Privacy Monitor][privacymonitor] is a client for ingesting the [Osano][osano] privacy rating API and displaying those scores to end users.

## Dependencies & Requirements

Privacy Monitor uses [Carthage] to import dependencies and build required frameworks. Verify that you have Carthage installed by typing ```carthage version```

If this command produces a numeric version number greater than 0.31 you have a recent version of Carthage installed.

[Apple Xcode][xl] v10 or greater is required to compile Privacy Monitor.

## Building

1. Clone this respository.
2. In Terminal, navigate to the local directory for this repository and run `carthage update --platform iOS`
3. 	Once Carthage has finished downloading and compiling all dependencies, open PrivacyMonitor.xcodeproj and have fun!

## Export Control

This distribution includes cryptographic software. The country in which you
currently reside may have restrictions on the import, possession, use, and/or
re-export to another country, of encryption software. BEFORE using any
encryption software, please check your country's laws, regulations and
policies concerning the import, possession, or use, and re-export of encryption
software, to see if this is permitted. See <http://www.wassenaar.org/> for more
information.

The U.S. Government Department of Commerce, Bureau of Industry and Security
(BIS), has classified this software as Export Commodity Control Number (ECCN)
5D002.C.1, which includes information security software using or performing
cryptographic functions with asymmetric algorithms. The form and manner of this
Apache Software Foundation distribution makes it eligible for export under the
License Exception ENC Technology Software Unrestricted (TSU) exception (see the
BIS Export Administration Regulations, Section 740.13) for both object code and
source code.

[privacymonitor]: https://www.privacymonitor.com
[logo]: Contrib/logo.png
[Carthage]: https://github.com/Carthage/Carthage
[osano]: https://www.osano.com
[li]: https://img.shields.io/badge/license-MIT-brightgreen.svg
[ll]: LICENSE
[pi]: https://img.shields.io/badge/platform-ios-lightgrey.svg
[pl]: http://developer.apple.com
[xl]: https://developer.apple.com/xcode/
