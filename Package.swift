// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WordPressKit", targets: ["WordPressKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wordpress-mobile/NSObject-SafeExpectations", from: "0.0.6"),
        .package(url: "https://github.com/wordpress-mobile/wpxmlrpc", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "WordPressKitObjCUtils",
        ),
        .target(
            name: "WordPressKitModels",
            dependencies: [
                "NSObject-SafeExpectations",
                "WordPressKitObjCUtils",
            ]
        ),
        .target(
            name: "WordPressKitObjC",
            dependencies: [
                "NSObject-SafeExpectations",
                "wpxmlrpc",
                "WordPressKitModels",
                "WordPressKitObjCUtils",
            ],
            publicHeadersPath: "include"
        ),
        .target(
            name: "WordPressKit",
            dependencies: [
                "WordPressKitObjC",
                "WordPressKitModels",
                "WordPressKitObjCUtils",
                "NSObject-SafeExpectations",
                "wpxmlrpc",
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
