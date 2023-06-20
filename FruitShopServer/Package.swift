// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FruitShopServer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "FruitShopServer", targets: ["FruitShopServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.62.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.2.0"),
        .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", exact: "1.30.0")
    ],
    targets: [
        .executableTarget(name: "FruitShopServer", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            "VaporToOpenAPI",
        ], resources: [
            .copy("Resources/Example Data"),
            .copy("Resources/Public"),
        ], plugins: [
        ]),
        .testTarget(name: "FruitShopServerTests", dependencies: [
            .target(name: "FruitShopServer"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
