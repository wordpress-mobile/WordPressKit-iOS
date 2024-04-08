// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "APIInterface", targets: ["APIInterface"]),
        .library(name: "CoreAPI", targets: ["CoreAPI"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "APIInterface"),
        .target(name: "CoreAPI"),
    ]
)
