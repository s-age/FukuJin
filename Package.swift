// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FukuJin",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.57.0"),
    ],
    targets: [
        .target(
            name: "CGSPrivate",
            path: "Sources/CGSPrivate",
            publicHeadersPath: "include"
        ),
        .executableTarget(
            name: "FukuJin",
            dependencies: ["CGSPrivate"],
            path: "Sources",
            exclude: ["CGSPrivate"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint"),
            ]
        ),
        .testTarget(
            name: "FukuJinTests",
            dependencies: ["FukuJin"],
            path: "Tests"
        ),
    ]
)
