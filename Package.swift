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
            url: "https://github.com/user-attachments/files/18647254/WordPressKit.zip",
            checksum: "6df9cf41df249237fd03eb09a4dd170b8ce80c4606ad839b2a71b44c5e8495fe"
        ),
    ]
)
