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
            url: "https://github.com/user-attachments/files/16200443/WordPressKit.zip",
            checksum: "09fde69ac4ca044a02ed52daa478c025c66fcfbf6cb5b64af2ab7959fc403508"
        ),
    ]
)
