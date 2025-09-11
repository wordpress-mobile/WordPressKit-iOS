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
            url: "https://github.com/user-attachments/files/22280239/WordPressKit.zip",
            checksum: "a2d46f654d72b367359606fefde01d43e44bee2034bfd079fa6334c378cfdb16"
        ),
    ]
)
