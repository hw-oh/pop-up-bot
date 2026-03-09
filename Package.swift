// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PopUpBot",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "PopUpBot",
            path: "Sources/PopUpBot",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit"),
                .linkedFramework("Carbon"),
            ]
        )
    ]
)
