// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "JelloSwift-WASM",
    products: [
        .executable(name: "JelloSwift-WASM", targets: ["JelloSwift-WASM"])
    ],
    dependencies: [
        .package(name: "JavaScriptKit", url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.9.0"),
        .package(url: "https://github.com/alvarhansen/JelloSwift", .branch("wasm")),
    ],
    targets: [
        .target(
            name: "JelloSwift-WASM",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "JelloSwift", package: "JelloSwift")
            ]),
        .testTarget(
            name: "JelloSwift-WASMTests",
            dependencies: ["JelloSwift-WASM"]),
    ]
)
