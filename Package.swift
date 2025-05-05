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
            url: "https://github.com/user-attachments/files/20039232/WordPressKit.zip",
            checksum: "6d0d9f96dbe6d810306e5b00635d65c61ae2a0409da519c462bf18f28801db55"
        ),
    ]
)
