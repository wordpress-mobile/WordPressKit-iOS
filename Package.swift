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
            url: "https://github.com/user-attachments/files/19732825/WordPressKit.zip",
            checksum: "0ecd8b19cd00a4ef363ab6e826f92166c1efa4693db8f3218533510a3f951dbb"
        ),
    ]
)
