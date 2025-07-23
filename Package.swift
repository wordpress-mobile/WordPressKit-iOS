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
            url: "https://github.com/user-attachments/files/21388771/WordPressKit.zip",
            checksum: "543f8dd4ee1bef8912c640aca0bfbb74db95e4577cc19fa82461edeeac45a02b"
        ),
    ]
)
