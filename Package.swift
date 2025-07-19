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
            url: "https://github.com/user-attachments/files/21328509/WordPressKit.zip",
            checksum: "e01a5e91e822b84058346b163663c88ee2ee50a9b1614804dbc0429567f00835"
        ),
    ]
)
