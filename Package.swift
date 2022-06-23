// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "DelegateFoundation",
  platforms: [
    .macOS(.v10_15), .iOS(.v13),
  ],
  products: [
    .library(
      name: "DelegateFoundation",
      targets: ["DelegateFoundation"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "DelegateFoundation",
      dependencies: [
      ]
    ),
    .testTarget(
      name: "DelegateFoundationTests",
      dependencies: ["DelegateFoundation"]
    ),
  ]
)
