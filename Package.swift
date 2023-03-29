// swift-tools-version:5.7

import PackageDescription

#if os(Linux)
let library: PackageDescription.Target = .systemLibrary(name: "clibxml2")
#elseif os(macOS)
let library: PackageDescription.Target = .systemLibrary(name: "clibxml2", pkgConfig: "libxml-2.0")
#endif

let package = Package(
    name: "libusb",
    products: [
        .library(name: "libxml2", targets: ["libxml2"]),
        .library(name: "clibxml2", targets: ["clibxml2"]),
        .executable(name: "test", targets: ["test"])
    ],
    targets: [
        .target(name: "libxml2", dependencies: ["clibxml2"]),
        library,
        .executableTarget(name: "test", dependencies: ["clibxml2"])
    ]
)

#if os(macOS)
package.platforms = [.macOS(.v13)]
#endif
