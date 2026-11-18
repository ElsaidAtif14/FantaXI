fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build_development

```sh
[bundle exec] fastlane android build_development
```

Build FantaXI Development APK

### android distribute_development

```sh
[bundle exec] fastlane android distribute_development
```

Distribute existing FantaXI Development APK to Firebase

----


## iOS

### ios build_unsigned_development

```sh
[bundle exec] fastlane ios build_unsigned_development
```

Build unsigned FantaXI Development for iOS

### ios build_unsigned_production

```sh
[bundle exec] fastlane ios build_unsigned_production
```

Build unsigned FantaXI Production for iOS

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
