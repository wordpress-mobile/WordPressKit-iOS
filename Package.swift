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
            url: "https://github.com/user-attachments/files/19318154/WordPressKit.zip",
            checksum: "769f4ec0c4e3712844af318962af7ffb417c8723c61688c913c381e6ac57e8b6"
        ),
    ]
)
