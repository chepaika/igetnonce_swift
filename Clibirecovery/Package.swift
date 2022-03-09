// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clibirecovery",
    products: [
        .library(name: "Clibirecovery", targets: ["Clibirecovery"]),
    ],
    targets: [
        .systemLibrary(
            name: "Clibirecovery",
            pkgConfig: "libirecovery-1.0",
            providers: [
                .brew(["libirecovery"]),
            ]
        )
    ]
)
