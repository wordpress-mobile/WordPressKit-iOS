// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "APIInterface", targets: ["APIInterface"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "APIInterface")
    ]
)
