#  WordPressKit for iOS

<!-- red -->
> [!CAUTION]
> This library is no longer fit for external contribution and community usage.
>
> [WordPress iOS](https://github.com/wordpress-mobile/WordPress-iOS) is its only consumer.
> The repo exists standalone rather than as part of the WordPress codebase because it's convenient to fetch this lump of code that rarely changes as a binary XCFramework dependency.
> See [#816](https://github.com/wordpress-mobile/WordPressKit-iOS/pull/816).

## XCFramework release instructions

- Run `.buildkite/create-xcframeworks.sh` to create binaries
- Upload `.build/xcframeworks/WordPressKit.zip` to this repo
- Update binary target in `Package.swift` with a new URL and checksum<sup>*</sup>
- Push the new changes to your branch
- After testing is done, merge changes into `trunk`

<sup>*</sup>_checksum is echoed at the end of the `create-xcframeworks.sh` script_

## About

WordPressKit offers a clean and simple WordPress.com and WordPress.org API.

## Requirements

- iOS 9 and above
- Xcode 9.3 and above

## Integrating the Library with CocoaPods

WordPressKit-iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod "WordPressKit"
```

## License

WordPressKit-iOS is available under the GPLv2 license. See the [LICENSE file](./LICENSE) for more info.
