// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuBarSpacer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MenuBarSpacer", targets: ["MenuBarSpacer"])
    ],
    targets: [
        .executableTarget(
            name: "MenuBarSpacer",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MenuBarSpacerTests",
            dependencies: ["MenuBarSpacer"],
            path: "Tests"
        )
    ]
)
