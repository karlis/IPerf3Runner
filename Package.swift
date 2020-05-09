// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "iperf3Runner",
    products: [
        .library(name: "iperf3Runner", targets: ["iperf3Runner"]),
    ],
    dependencies: [
         .package(url: "https://github.com/karlis/ciperf3", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "iperf3Runner",
            dependencies: ["ciperf3"]),
        .testTarget(
            name: "iperf3RunnerTests",
            dependencies: ["iperf3Runner"]),
    ]
)
