// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "igetnonce",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(name: "Clibirecovery", path: "../Clibirecovery"),
        .package(name: "Clibimobiledevice", path: "../Clibimobiledevice"),
        .package(name: "Clibplist", path: "../Clibplist"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "igetnonce",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Clibirecovery", package: "Clibirecovery"),
                .product(name: "Clibimobiledevice", package: "Clibimobiledevice"),
                .product(name: "Clibplist", package: "Clibplist"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "igetnonceTests",
            dependencies: ["igetnonce"]),
    ]
)
