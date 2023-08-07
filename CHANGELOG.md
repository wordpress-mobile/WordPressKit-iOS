# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## <version_number>`
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

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

## 8.5.1

### Bug Fixes

- Correctly set `mime_type` in media library count API calls [#620]

## 8.5.0

### New Features

- Add `IPLocationRemote` [#613]
- Add `ui_status` field to `BlazeCampaign` [#611]

## 8.4.0

### New Features

- Add new endpoint to fetch Jetpack Social Publicize configurations [#606]
- Add `can_blaze` property to blog options [#609]

## 8.3.0

### New Features

- Add Blaze campaigns search endpoint [#605]

## 8.2.0

### New Features

- Add WordPress.com `/v2` external services endpoint [#600]

## 8.1.0

### Internal Changes

- Update editor settings models for block based themes [#598]

## 8.0.0

### Breaking Changes

- `Activity` now conforms to `Decodable` and no longer offers `init(dictionary:)` [#591] – _This was originally shipped as 7.2.0 before we realized it was a breaking change._

## 7.2.0

### New Features

- `Activity` now conforms to `Decodable` [#591]

## 7.1.0

### New Features

- Add POST requests method to `WordPressOrgRestApi`. [#589]

## 7.0.0

### Breaking Changes

- Refactor the logic to fetch metadata of VideoPress videos [#581]

### New Features

- Add ability to fetch free and paid domains. [#585]

## 6.2.0

_This should have been 6.1.1 because there was only a bug fix, but I realized it only after the release had already been published on CocoaPods. – @mokagio_

### Bug Fixes

- Changes the feature flag platform identifier to `ios` [#582]

## 6.1.0

### New Features

- Add remote to make requests to self-hosted, Jetpack-connected sites via the Jetpack Proxy API [#576]
- Add Blaze status endpoint [#577]

### Bug Fixes

- Fixes regression in logic to decode whether user has a free plan from JSON [#578]

## 6.0.0

### Breaking Changes

- Re-implement a few reader model types in Swift. [#556, #557, #558]
- Implicityly Unwrapped Optionals in some model types are removed. [#569]

### New Features

- Add `twoStepEnabled` property to `AccountSettings` model. [#567]

### Bug Fixes

_None._

### Internal Changes

- Change the `NSObject+SafeExpectations` dependency to `~> 0.0.4`. [#555]
- Use Xcode 14.2 on CI. [#568]

## 5.0.0

### Breaking Changes

- Remove CocoaLumberjack. Use `WPKitSetLoggingDelegate` to assign a logger to this library. [#550]

### Internal Changes

- Add this changelog file. [#545]
