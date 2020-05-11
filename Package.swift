// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "IPerf3Runner",
  products: [
    .library(name: "IPerf3Runner", targets: ["IPerf3Runner"]),
  ],
  dependencies: [
    .package(url: "https://github.com/karlis/ciperf3", from: "1.0.3"),
  ],
  targets: [
    .target(name: "IPerf3Runner", dependencies: ["ciperf3"]),
    .testTarget(name: "IPerf3RunnerTests", dependencies: ["IPerf3Runner"]),
  ]
)
