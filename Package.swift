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
            url: "https://github.com/user-attachments/files/19949939/WordPressKit.zip",
            checksum: "ba06ff0716595023dd6c98b6a5bc74d4abb35bfb668e24026ffd041460f59137"
        ),
    ]
)
