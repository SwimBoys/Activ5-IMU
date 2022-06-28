// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Activ5-IMU",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Activ5-IMU",
            targets: ["Activ5-IMU"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Activ5Device", url: "https://github.com/Activbody-ChinaJV/activ5-ios-bluetooth", .branch("develop")),
        .package(url: "https://github.com/martin-key/Hamilton", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Activ5-IMU",
            dependencies: ["Activ5Device", "Hamilton"]),
        .testTarget(
            name: "Activ5-IMUTests",
            dependencies: ["Activ5-IMU"]),
    ]
)
