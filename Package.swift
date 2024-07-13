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
            url: "https://github.com/user-attachments/files/16200320/WordPressKit.zip",
            checksum: "fa2ddc1fedcc225beb23d23168043bd78bbd12d43e187cc0dd772aef8d81ee20"
        ),
    ]
)
