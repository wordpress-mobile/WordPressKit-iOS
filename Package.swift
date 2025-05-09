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
            url: "https://github.com/user-attachments/files/20123946/WordPressKit.zip",
            checksum: "e7905c7d063682c3a3433b4b36578169081c74895db02ec55ec8de2745c799ef"
        ),
    ]
)
