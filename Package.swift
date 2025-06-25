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
            url: "https://github.com/user-attachments/files/20895757/WordPressKit.zip",
            checksum: "b08eaf182f0399303aadccb1a6dad6cad294a9c8d123d920889b15950c85e08f"
        ),
    ]
)
