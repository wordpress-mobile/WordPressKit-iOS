# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## [<version_number>](https://github.com/wordpress-mobile/WordPressKit-iOS/releases/tag/<version_number>)`
3. Add a new "Unreleased" section for the next iteration, by copy/pasting the following template:

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

-->

## Unreleased

### Breaking Changes

- Re-implement a few reader model types in Swift. [#556, #557, #558]

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

- Change the NSObject+SafeExpectations dependency to `~> 0.0.4`. [#555]

## [5.0.0](https://github.com/wordpress-mobile/WordPressKit-iOS/releases/tag/5.0.0)

### Breaking Changes

- Remove CocoaLumberjack. Use `WPKitSetLoggingDelegate` to assign a logger to this library. [#550]

### Internal Changes

- Add this changelog file. [#545]
