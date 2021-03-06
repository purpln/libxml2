// swift-tools-version:5.3

import PackageDescription
#if os(Linux)
let library: PackageDescription.Target = .systemLibrary(name: "clibxml2")
#else
let library: PackageDescription.Target = .systemLibrary(name: "clibxml2", pkgConfig: "libxml-2.0")
#endif
let package = Package(
    name: "libxml2",
    products: [.library(name: "libxml2", targets: ["libxml2"]), .library(name: "clibxml2", targets: ["clibxml2"])],
    targets: [library, .target(name: "libxml2", dependencies: ["clibxml2"])]
)
