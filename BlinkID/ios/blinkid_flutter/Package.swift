// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "blinkid_flutter",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "blinkid-flutter", targets: ["blinkid_flutter"])
  ],
  dependencies: [
    .package(url: "https://github.com/microblink/blinkid-ios.git", exact: .init(8000, 0, 0)),
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    .target(
      name: "blinkid_flutter",
      dependencies: [
        .product(name: "BlinkIDUX", package: "blinkid-ios"),
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      resources: []
    )
  ]
)
