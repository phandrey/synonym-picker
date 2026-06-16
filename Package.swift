// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SynonymPickerMac",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "SynonymPickerCore",
      targets: ["SynonymPickerCore"]
    ),
    .executable(
      name: "SynonymPicker",
      targets: ["SynonymPickerApp"]
    ),
  ],
  targets: [
    .target(
      name: "SynonymPickerCore"
    ),
    .executableTarget(
      name: "SynonymPickerApp",
      dependencies: ["SynonymPickerCore"]
    ),
    .testTarget(
      name: "SynonymPickerCoreTests",
      dependencies: ["SynonymPickerCore"]
    ),
  ]
)
