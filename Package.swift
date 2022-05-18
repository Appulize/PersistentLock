// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimedLock",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "TimedLock",
            targets: ["TimedLock"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Appulize/AppulizeStandardTools.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "TimedLock",
            dependencies: ["AppulizeStandardTools"]
        ),
    ]
)
