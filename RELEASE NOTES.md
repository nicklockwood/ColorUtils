Version 1.1.1

_ Fixed some type mismatch warnings affecting arm64 builds

Version 1.1

- Now requires ARC
- Added registerColor:forName: method for adding bespoke named colors
- Added colorWithBrightness: and colorBlendedWithColor: methods
- Now complies with -Wextra warning level
- Added CocoaPods podspec file

Version 1.0.3

- Moved ARCHelper macros out of .h file
- Renamed class files for future flexibility
- Updated example for iOS6 and ARC

Version 1.0.2

- Added automatic support for ARC compile targets
- Now requires Apple LLVM 3.0 compiler target

Version 1.0.1

- Fixed potential crash due to an incorrect retain count when initialising colors using a name string, e.g. 'blue'.

Version 1.0

- Initial release