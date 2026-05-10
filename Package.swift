// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Timecount",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Timecount", targets: ["Timecount"])
    ],
    targets: [
        .executableTarget(
            name: "Timecount",
            path: "Sources/Timecount",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TimecountTests",
            dependencies: ["Timecount"],
            path: "Tests/TimecountTests"
        ),
    ]
)
