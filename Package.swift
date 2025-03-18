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
            url: "https://github.com/user-attachments/files/19329510/WordPressKit.zip",
            checksum: "79d86c26fb143779b25634a042f740343a046ebf615d7b7117b4756c98a1f91f"
        ),
    ]
)
