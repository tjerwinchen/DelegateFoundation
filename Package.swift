// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "DelegateProxy",
  platforms: [
    .macOS(.v10_15), .iOS(.v13),
  ],
  products: [
    .library(
      name: "DelegateProxy",
      targets: ["DelegateProxy"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "DelegateProxy",
      dependencies: [
      ]
    ),
    .testTarget(
      name: "DelegateProxyTests",
      dependencies: ["DelegateProxy"]
    ),
  ]
)
