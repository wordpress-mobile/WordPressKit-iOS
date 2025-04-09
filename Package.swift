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
            url: "https://github.com/user-attachments/files/19658656/WordPressKit.zip",
            checksum: "9172f9b9906e64efe1f3d79f074ad317f1d40c6ce1ec394259b0f99fea6fe8ee"
        ),
    ]
)
