// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NotificationSyncer",
    products: [
        .library(
            name: "NotificationSyncer",
            targets: ["NotificationSyncer"]
        ),
    ],
    targets: [
        .target(name: "NotificationSyncer"),
        .testTarget(name: "NotificationSyncerTests", dependencies: ["NotificationSyncer"]),
    ]
)
