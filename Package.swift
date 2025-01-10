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
            url: "https://github.com/user-attachments/files/18378391/WordPressKit.zip",
            checksum: "afba972825502b7479ee7dd6bdbe88cda630d19c95f372b85ffc760b9ba60aac"
        ),
    ]
)
