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
            url: "https://github.com/user-attachments/files/20067014/WordPressKit.zip",
            checksum: "e20c387a1c32306e502326af03f46629140b9d1bc994de3c614890a0fd24b690"
        ),
    ]
)
