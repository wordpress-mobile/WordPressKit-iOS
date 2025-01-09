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
            url: "https://github.com/user-attachments/files/18209758/WordPressKit.zip",
            checksum: "2c9fa7ed59864c01c8af7dc0b5dd8cbc26558799487fad3ab9e128cfbd8dae64"
        ),
    ]
)
