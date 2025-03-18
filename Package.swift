// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WordPressKit", targets: ["WordPressKit"]),
    ],
    targets: [
        .binaryTarget(
            name: "WordPressKit",
            url: "https://github.com/user-attachments/files/19034191/WordPressKit.zip",
            checksum: "34f108cba86b5e4334d1c9af79946dbb8b665e270bdd14bc8f7bc0ba7a898583"
        ),
    ]
)
