// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [
        .iOS(.v13),
        // The package(s) are meant for iOS only, but the use of the SwiftLint plugin down the dependency chain requires specifying a compatible macOS version.
        .macOS(.v12),
    ],
    products: [
        .library(name: "APIInterface", targets: ["APIInterface"]),
        .library(name: "CoreAPI", targets: ["CoreAPI"]),
    ],
    dependencies: [
        // .package(url: "https://github.com/wordpress-mobile/WordPress-iOS-Shared.git", from: "2.3.1"),
        // See https://github.com/wordpress-mobile/WordPress-iOS-Shared/pull/354
        .package(url: "https://github.com/wordpress-mobile/WordPress-iOS-Shared.git", branch: "mokagio/swiftlint-read-as-dependency"),
        .package(url: "https://github.com/wordpress-mobile/wpxmlrpc", from: "0.10.0"),
        // Test dependencies
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.1"),
    ],
    targets: [
        .target(name: "APIInterface"),
        .target(
            name: "CoreAPI",
            dependencies: [
                .product(name: "WordPressShared", package: "WordPress-iOS-Shared"),
                "wpxmlrpc"
            ]
        ),
    ]
)
