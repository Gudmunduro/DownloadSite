// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "DownloadSite",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),

        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),

        // Error middleware using leaf
        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Leaf", "Vapor", "LeafErrorMiddleware"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

