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
            url: "https://github.com/user-attachments/files/20066712/WordPressKit.zip",
            checksum: "0663dd7a2608185cdd5cabb99046cd0146d6ef22a446cf8d2c123823d813b813"
        ),
    ]
)
