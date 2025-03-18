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
            url: "https://github.com/user-attachments/files/19325003/WordPressKit.zip",
            checksum: "7bab7fb007c1c2bb8b83d0495c32849594451e2d961d289dcee39b84d9c90ebc"
        ),
    ]
)
