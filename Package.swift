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
            url: "https://github.com/user-attachments/files/20106710/WordPressKit.zip",
            checksum: "718a32f677c5ce49bd69f7cb0c8605993370f423aa8f088deab99a6f40dc45ac"
        ),
    ]
)
