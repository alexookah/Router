// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Router",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Router",
            targets: ["Router"]
        )
    ],
    targets: [
        .target(
            name: "Router"
        ),
        .testTarget(
            name: "RouterTests",
            dependencies: ["Router"]
        )
    ]
)
