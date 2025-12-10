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
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.8.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "RFC 5234",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
            ]
        ),
        .testTarget(
            name: "RFC 5234".tests,
            dependencies: [
                "RFC 5234",
                .product(name: "StandardsTestSupport", package: "swift-standards")
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
