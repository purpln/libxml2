// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "libxml2", products: [
    .library(name: "libxml2", targets: ["libxml2"]),
], targets: [
    .systemLibrary(name: "libxml2", pkgConfig: "libxml-2.0"),
])
