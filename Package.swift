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
            url: "https://github.com/user-attachments/files/20087743/WordPressKit.zip",
            checksum: "138689853d7a65384fa5dae5b5732b40769689a0108f4265e23cc47ca3eea647"
        ),
    ]
)
