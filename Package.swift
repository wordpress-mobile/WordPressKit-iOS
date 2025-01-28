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
            url: "https://github.com/user-attachments/files/18570063/WordPressKit.zip",
            checksum: "fc25d3065e80af713dac970db7ed89ff37e4cc98afc98b6a2ecf7b47b2ddd0c1"
        ),
    ]
)
