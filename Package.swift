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
            url: "https://github.com/user-attachments/files/20038416/WordPressKit.zip",
            checksum: "fa431397e9124b49562fbc5b4f0dccd238fe28f8744826e9a26d14ca57860173"
        ),
    ]
)
