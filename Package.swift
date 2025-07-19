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
            url: "https://github.com/user-attachments/files/21335415/WordPressKit.zip",
            checksum: "bed68c5416321ef59721805f4bb31ec5fc198b57f73f35250e9b35a5cb5fbd5e"
        ),
    ]
)
