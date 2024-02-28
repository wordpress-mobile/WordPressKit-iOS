// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "WordPressKit",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "RFC3339",
      targets: ["RFC3339"]
    ),
    .library(
      name: "CoreAPI",
      targets: ["CoreAPI"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/wordpress-mobile/WordPress-iOS-Shared.git", from: "2.3.0"),
    .package(url: "https://github.com/wordpress-mobile/wpxmlrpc", from: "0.10.0"),
    // Test dependencies
    .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.1"),
  ],
  targets: [
    .target(
      name: "RFC3339",
      path: "RFC3339",
      publicHeadersPath: "."  // publicHeadersPath is relative to path
    ),
    .target(
      name: "CoreAPI",
      dependencies: [
        .product(name: "WordPressShared", package: "WordPress-iOS-Shared"),
        "wpxmlrpc",
      ],
      path: "CoreAPI"
    ),
    .testTarget(
      name: "CoreAPITests",
      dependencies: [
        .target(name: "CoreAPI"),
        .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
        .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
        "Alamofire",
      ],
      path: "CoreAPITests",
      resources: [
        .copy("Stubs")
      ]
    ),
  ]
)
