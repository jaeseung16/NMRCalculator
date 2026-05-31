// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NMRCalculatorCommon",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NMRCalculatorCommon",
            targets: ["NMRCalculatorCommon"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.13.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NMRCalculatorCommon",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Resources/NMRFreqTable_2026.csv")
            ],
        ),
        .testTarget(
            name: "NMRCalculatorCommonTests",
            dependencies: ["NMRCalculatorCommon"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
