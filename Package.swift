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
            url: "https://github.com/user-attachments/files/21582269/WordPressKit.zip",
            checksum: "cbfe79d7a4244302d308027ff329f1ccdfd1c604d990871359764eca567ea86f"
        ),
    ]
)
