// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clibplist",
    products: [
        .library(name: "Clibplist", targets: ["Clibplist"]),
    ],
    targets: [
        .systemLibrary(
            name: "Clibplist",
            pkgConfig: "libplist-2.0",
            providers: [
                .brew(["libplist"])
            ]
        )
    ]
)
