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
            url: "https://github.com/user-attachments/files/20801891/WordPressKit.zip",
            checksum: "a64680b161f04e5431109b2fcc513ed83356793309b3e1ba8d2fd0a8d128a3c9"
        ),
    ]
)
