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
            url: "https://github.com/user-attachments/files/21328342/WordPressKit.zip",
            checksum: "fb23d0f4768e6a3017f96e220f3e54b1be264cab8161887d3b16109e32d2799f"
        ),
    ]
)
