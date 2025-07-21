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
            url: "https://github.com/user-attachments/files/21352383/WordPressKit.zip",
            checksum: "8054b66ecf39b8c23acea6d8c5c6c9f65fda01fcce4da7acf7db4273cb8e9145"
        ),
    ]
)
