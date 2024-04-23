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

### New Features

- Add `getPost(withID)` to `PostServiceRemoteExtended` [#785]
- Add support for metadata to `PostServiceRemoteExtended` [#783]
- Add fetching of `StatsEmailsSummaryData` to `StatsService` [#794]
- Add fetching of `StatsSubscribersSummaryData` to `StatsService` [#795]

### Bug Fixes

- Fix encoding for some fields in the new XMLRPC endpoints [#786]
- Fix an issue with parent page removal in new `PostServiceRemoteExtended` [#796]

### Internal Changes

- Update new APIs to create and update posts introduced `PostServiceRemoteExtended` to use `wp.newPost` and `wp.editPost` instead of the older versions of these APIs [#792]


## 17.0.0

### Breaking Changes

- Removed `anonymousWordPressComRestApiWithUserAgent` method from `ServiceRemoteWordPressComREST` [#778]
- Renamed `ServiceRemoteWordPressComRESTApiVersion` to `WordPressComRestAPIVersion` [#778]

### New Features

- Add new delete endpoint [#776]
- Add support for metadata for `RemotePostParameters` [#783]

### Bug Fixes

_None._

### Internal Changes

- Make Stats-related entities Equatable [#751]
- Fix looking up multipart form temporary file [#781]

## 16.0.0

### Breaking Changes

- Changes the structure of `StatsAnnualAndMostPopularTimeInsight` to more accurately reflect JSON response. [#763]
- Reworked the `NSDate` RFC3339 / WordPress.com JSON conversions API [#759]

### Internal Changes

- Improved parsing using Codable for Stats Insight entities. [#763]

## 15.0.0

### Breaking Changes

- Reworked the `NSDate` RFC3339 / WordPress.com JSON conversions API [#759]
- Changed `FilePart` `filename` property to `fileName` [#765]

### Bug Fixes

- Fix crash when querying a WordPress plugin whose slug is not url-safe. [#767]

## 14.1.0

### New Features

- Add Reader discover streams endpoint. [#744]

### Bug Fixes

- Fix a rare crash when accessing date formatter from different threads in StatsRemoteService. [#749]

### Internal Changes

- Add WP.com theme type information. [#750]
- Add `page` and `number` parameters to fetchFollowedSites in `ReaderTopicServiceRemote` [#753]

## 14.0.1

### Bug Fixes

- Fix parsing issues in getting Zendesk metadata and feature announcements. [#746]

## 14.0.0

### Breaking Changes

- Rewrite `WordPressOrgRestApi` to support self hosted sites and WordPress.com sites. [#724]
- Decouple `PluginDirectoryServiceRemote` from Alamofire. [#725]
- Remove `Endpoint`. [#725]

### Bug Fixes

- Fix crash when uploading files using background `URLSession`. [#739]

## 13.1.0

### New Features

- `StatsTimeIntervalData` now accepts an optional `unit: StatsPeriodUnit` parameter that allows to describe the granularity of data fetched for a given period. [#712]

### Internal Changes

- When enabled, `WordPressComRestApi` sends HTTP requests using URLSession instead of Alamofire. [#720]
- When enabled, `WrodPressOrgXMLRPCApi` sends HTTP requests using URLSession instead of Alamofire. [#719]
- Refactor API requests that ask for SMS code during WP.com authentication. [#683]
- Refactor BlazeServiceRemote to use URLSession-backed API. [#721]
- Refactor some WP.com API endpoints to use URLSession-backed API. [#722]

## 13.0.0

### Breaking Changes

- Remove `userIP` from `AtomicWebServerLogEntry`. [#711]

### Internal Changes

- Various internal changes in preparation to remove Alamofire.

## 12.0.0

### Breaking Changes

- `WordPressComRestApiError` is renamed to `WordPressRestApiErrorCode`, and no longer conforms to `Swift.Error`. [#696]

### New Features

- Add `AtomicSiteServiceRemote` [#704]

### Bug Fixes

- XMLRPC API progress is now always updated on the main thread. [#714]

### Internal Changes

_None._

## 11.0.0

### Breaking Changes

- `WordPressComRestApi` initialisers now accept a `baseURL: URL` parameter instead of `baseUrlString: String`. [#691]
- Removed the async functions in `WordPressComRestApi`. [#692]
- URL parameters in `WordPressComOAuthClient` initialisers are now declared as `URL` type, instead of `String`. [#698]

### Internal Changes

- Refactor WP.com authentication API requests. [#660, #661, #681]

## 10.0.0

### Breaking Changes

- Add a new `unacceptableStatusCode` error case to `WordPressAPIError`. [#668]
- The `deviceId` parameter in `DashboardServiceRemote` is now non-optional. [#678]

### Bug Fixes

- Fix a bug in parsing XMLRPC link from a RSD Link. [#671]

## 9.0.3

_Note: This version should have been 9.1.0, because it introduces a new feature._
_However, WordPressAuthenticator currently depends on WordPressKit via `~> 9.0.0` which would result in this version being incompatible._
_In the interest of minimizing changes in the WordPress [24.0](https://github.com/wordpress-mobile/WordPress-iOS/milestone/265) release, we shipped this as 9.0.3 and decided to follow up in WordPressAuthenticator separately._

### New Features

- Add `deviceId` param to `DashboardServiceRemote.fetch` method. [#674]

## 9.0.2

### Bug Fixes

- Improve XML-RPC error messages to suggest contacting the host. [#655]

## 9.0.1

### Internal Changes

- Fix `WordPressAPIError`'s localized error message. [#662]

## 9.0.0

### Breaking Changes

- `WordPressComOAuthError` now conforms to `Swift.Error` [#650]

### New Features

- `WordPressOrgXMLRPCValidatorError` now conforms to `LocalizedError` [#649]

## 8.11.0

### New Features

- Add `tag` parameter to `PostServiceRemoteOptions` [#634]
- Add `transfer` case to `DomainType` case [#642]

## 8.10.0

### New Features

- Add optional `tag` parameter to `PostServiceRemoteOptions` [#640]
- Add support for creating a shopping cart that's not tied to a specific site. [#644]

## 8.9.1

### Bug Fixes

- Reverted adding `tag` parameter to `PostServiceRemoteOptions`. Breaking change in 8.8.0. [#639]

## 8.9.0

### New Features

- Add API to get a post's latest revision id [#637]

## 8.8.0

### New Features

- Add `tag` parameter to `PostServiceRemoteOptions` [#634]

## 8.7.1

### Bug Fixes

- `RemotePostCategory.parent` is set to zero when API returns `"parent": null` [#630]
- Fixed a breaking changes introduced in 8.7.0 [#632, #633]

## 8.7.0

- Update `WordPressComOAuthClient` to add support to webauthn endpoints [#629]

## 8.6.0

### New Features

- Add `createShoppingCart` method to add domains and plans when creating a new cart [#628]

## 8.5.2

### Bug Fixes

- Exclude dot blog subdomains from freeAndPaid domain query [#627]

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
