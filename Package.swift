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
            url: "https://github.com/user-attachments/files/21420518/WordPressKit.zip",
            checksum: "c57f60d8476cb1ba7000a2aa1fe0607794e1660c964d31ddab6e5add5db70499"
        ),
    ]
)
