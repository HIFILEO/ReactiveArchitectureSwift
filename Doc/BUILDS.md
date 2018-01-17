# BUILDS.md

This project is built to use Swift 4 and XCODE 11 running on a Mac.

### Usage

This document describes official test and production builds.
There are two types of signing, build types, and product environments inside the flavors.

#### Build Types

1. **Debug**
3. **Release**

**Debug** builds are intended to be used by the developers.
They have debug enabled while signing with the standard debug keystore.

These builds will also have developer tools integrated whenever possible.

**Release** builds are intended to be published in the Android stores.
All debugging features are disabled.
The apk is signed with the release keystore. (Not this example app)

#### Environment Flavors

The build's environment flavor specifies which set of endpoints the app will use for various services. For this
example there are no flavors.
