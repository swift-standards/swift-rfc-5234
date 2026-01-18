// swift-tools-version: 6.2

import PackageDescription

// RFC 5234: Augmented BNF for Syntax Specifications: ABNF
//
// Implements RFC 5234 ABNF (Augmented Backus-Naur Form) for defining
// syntax specifications used throughout IETF standards.
//
// ABNF is a metalanguage for describing the syntax of protocols and
// data formats. It provides a formal notation for specifying grammars
// with terminals, rules, repetition, alternatives, and grouping.
//
// This is a pure Swift implementation with no Foundation dependencies,
// suitable for Swift Embedded and constrained environments.

let package = Package(
    name: "swift-rfc-5234",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "RFC 5234",
            targets: ["RFC 5234"]
        )
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-test-primitives"),
        .package(path: "../../swift-foundations/swift-ascii")
    ],
    targets: [
        .target(
            name: "RFC 5234",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "ASCII", package: "swift-ascii")
            ]
        ),
        .testTarget(
            name: "RFC 5234".tests,
            dependencies: [
                "RFC 5234",
                .product(name: "Test Primitives", package: "swift-test-primitives")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
