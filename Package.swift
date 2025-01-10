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
            url: "https://github.com/user-attachments/files/18379301/WordPressKit.zip",
            checksum: "afd882de3a6a672c32c6cc7e6e1c1e68ff4e1366e7613af4eab59415ed7abb59"
        ),
    ]
)
