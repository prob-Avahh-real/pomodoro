// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Pomodoro",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Pomodoro", targets: ["Pomodoro"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pomodoro",
            path: "Sources/Pomodoro"
        ),
        .testTarget(
            name: "PomodoroTests",
            dependencies: ["Pomodoro"],
            path: "Tests/PomodoroTests"
        ),
    ]
)
