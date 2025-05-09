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
            url: "https://github.com/user-attachments/files/20127687/WordPressKit.zip",
            checksum: "bbc81f893eb080a176d018f53d85e6747e529799309c0245c9e204053e75e138"
        ),
    ]
)
