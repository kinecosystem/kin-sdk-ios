// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KinUtil",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "KinUtil",
            targets: ["KinUtil"]),
    ],
    dependencies: [
    ],
    targets: [
	.target(
	    name: "KinUtil",
	    dependencies: []),
    ]
)

