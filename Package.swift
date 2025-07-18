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
            url: "https://github.com/user-attachments/files/21322294/WordPressKit.zip",
            checksum: "1e00efe677045ce0fa0ace9998a8768b83afa3deb3eccb5faed2d17a0d41b364"
        ),
    ]
)
