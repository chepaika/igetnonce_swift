// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clibimobiledevice",
    //platforms: [
        //.macOS(.v12)
    //],
    products: [
        .library(name: "Clibimobiledevice", targets: ["Clibimobiledevice"]),
    ],
    targets: [
        .systemLibrary(
            name: "Clibimobiledevice",
            pkgConfig: "libimobiledevice-1.0",
            providers: [
                .brew(["libimobiledevice", "openssl"])
            ]
        )
    ]
)
