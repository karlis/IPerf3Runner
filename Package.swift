// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "IPerf3Runner",
  products: [
    .library(name: "IPerf3Runner", targets: ["IPerf3Runner"]),
    .library(name: "ciperf3", targets: ["ciperf3"]),
  ],
  targets: [
    .target(name: "IPerf3Runner", dependencies: ["ciperf3"]),
    .testTarget(name: "IPerf3RunnerTests", dependencies: ["IPerf3Runner"]),
    .target(name: "ciperf3", path: "./Sources/ciperf3"),
  ]
)
