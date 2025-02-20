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
            url: "https://github.com/user-attachments/files/19034071/WordPressKit.zip",
            checksum: "56b34223272bd84b4530591889b274f6fc4781b62abe9b0dc0e6ae2f3c364442"
        ),
    ]
)
