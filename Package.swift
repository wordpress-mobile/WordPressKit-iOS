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
            url: "https://github.com/user-attachments/files/17435861/WordPressKit.zip",
            checksum: "af7239442da8470a91ef5ab923fd91222bb3c0ea345b18f581bfafd63f0dd6b6"
        ),
    ]
)
