// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "ProductApp",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "ProductApp",
            targets: ["AppModule"],
            bundleIdentifier: "de.pruefungsleistung.ProductApp",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", "6.11.0"..<"6.12.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "GRDB", package: "grdb.swift")
            ],
            path: "."
        )
    ]
)