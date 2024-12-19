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
            url: "https://github.com/user-attachments/files/18203178/WordPressKit.zip",
            checksum: "ceb5ac66cda7b207f123319d6c04c338b90b7657344e7f395f86d36ff9e61f4a"
        ),
    ]
)
