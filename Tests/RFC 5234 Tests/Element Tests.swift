// Element Tests.swift
// swift-rfc-5234
//
// Tests for RFC_5234.Element

import RFC_5234
import Testing

@Suite("RFC_5234.Element - Sequence")
struct ElementSequenceTests {
    @Test
    func `Sequence matches concatenated elements`() throws {
        // "AB" = sequence of "A" then "B"
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        try RFC_5234.Validator.validate([0x41, 0x42], against: rule)
    }

    @Test
    func `Sequence rejects partial match`() {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: rule)  // Only "A"
        }
    }

    @Test
    func `Sequence rejects wrong order`() {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x42, 0x41], against: rule)  // "BA"
        }
    }

    @Test
    func `Empty sequence matches empty input`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([])
        )

        try RFC_5234.Validator.validate([], against: rule)
    }
}

@Suite("RFC_5234.Element - Alternation")
struct ElementAlternationTests {
    @Test
    func `Alternation matches first option`() throws {
        // "A" / "B"
        let rule = RFC_5234.Rule(
            name: "test",
            element: .alternation([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        try RFC_5234.Validator.validate([0x41], against: rule)
    }

    @Test
    func `Alternation matches second option`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .alternation([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        try RFC_5234.Validator.validate([0x42], against: rule)
    }

    @Test
    func `Alternation rejects non-matching input`() {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .alternation([
                .terminal(.byte(0x41)),  // A
                .terminal(.byte(0x42)),  // B
            ])
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x43], against: rule)  // C
        }
    }

    @Test
    func `Alternation with many options`() throws {
        // Test HEXDIG-like: 0-9 / A-F
        let rule = RFC_5234.Rule(
            name: "test",
            element: .alternation([
                .terminal(.byteRange(0x30, 0x39)),  // 0-9
                .terminal(.string("A")),
                .terminal(.string("B")),
                .terminal(.string("C")),
            ])
        )

        try RFC_5234.Validator.validate([0x35], against: rule)  // 5
        try RFC_5234.Validator.validate([0x41], against: rule)  // A
        try RFC_5234.Validator.validate([0x43], against: rule)  // C
    }
}

@Suite("RFC_5234.Element - Optional")
struct ElementOptionalTests {
    @Test
    func `Optional matches when present`() throws {
        // [A]
        let rule = RFC_5234.Rule(
            name: "test",
            element: .optional(.terminal(.byte(0x41)))  // [A]
        )

        try RFC_5234.Validator.validate([0x41], against: rule)
    }

    @Test
    func `Optional matches when absent`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .optional(.terminal(.byte(0x41)))  // [A]
        )

        try RFC_5234.Validator.validate([], against: rule)
    }

    @Test
    func `Optional in sequence`() throws {
        // A [B] C
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .terminal(.byte(0x41)),  // A
                .optional(.terminal(.byte(0x42))),  // [B]
                .terminal(.byte(0x43)),  // C
            ])
        )

        try RFC_5234.Validator.validate([0x41, 0x42, 0x43], against: rule)  // ABC
        try RFC_5234.Validator.validate([0x41, 0x43], against: rule)  // AC
    }
}

@Suite("RFC_5234.Element - Repetition")
struct ElementRepetitionTests {
    @Test
    func `Repetition 0 or more (*) matches zero`() throws {
        // *A
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 0, max: nil)
        )

        try RFC_5234.Validator.validate([], against: rule)
    }

    @Test
    func `Repetition 0 or more (*) matches one`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 0, max: nil)
        )

        try RFC_5234.Validator.validate([0x41], against: rule)  // A
    }

    @Test
    func `Repetition 0 or more (*) matches many`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 0, max: nil)
        )

        try RFC_5234.Validator.validate([0x41, 0x41, 0x41], against: rule)  // AAA
    }

    @Test
    func `Repetition 1 or more (1*) requires at least one`() {
        // 1*A
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 1, max: nil)
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([], against: rule)
        }
    }

    @Test
    func `Repetition 1 or more (1*) accepts one`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 1, max: nil)
        )

        try RFC_5234.Validator.validate([0x41], against: rule)
    }

    @Test
    func `Repetition 1 or more (1*) accepts many`() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 1, max: nil)
        )

        try RFC_5234.Validator.validate([0x41, 0x41], against: rule)
    }

    @Test
    func `Repetition with max (2*4)`() throws {
        // 2*4A = 2 to 4 occurrences
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 2, max: 4)
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: rule)  // Too few
        }

        try RFC_5234.Validator.validate([0x41, 0x41], against: rule)  // 2 ✓
        try RFC_5234.Validator.validate([0x41, 0x41, 0x41], against: rule)  // 3 ✓
        try RFC_5234.Validator.validate([0x41, 0x41, 0x41, 0x41], against: rule)  // 4 ✓

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41, 0x41, 0x41, 0x41, 0x41], against: rule)  // Too many
        }
    }

    @Test
    func `Exact repetition (3A)`() throws {
        // 3A = exactly 3
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(.terminal(.byte(0x41)), min: 3, max: 3)
        )

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41, 0x41], against: rule)  // Too few
        }

        try RFC_5234.Validator.validate([0x41, 0x41, 0x41], against: rule)  // Exact ✓

        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41, 0x41, 0x41, 0x41], against: rule)  // Too many
        }
    }
}

@Suite("RFC_5234.Element - Complex Combinations")
struct ElementComplexTests {
    @Test
    func `Sequence of alternations`() throws {
        // (A / B) (C / D)
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .alternation([
                    .terminal(.byte(0x41)),  // A
                    .terminal(.byte(0x42)),  // B
                ]),
                .alternation([
                    .terminal(.byte(0x43)),  // C
                    .terminal(.byte(0x44)),  // D
                ]),
            ])
        )

        try RFC_5234.Validator.validate([0x41, 0x43], against: rule)  // AC
        try RFC_5234.Validator.validate([0x41, 0x44], against: rule)  // AD
        try RFC_5234.Validator.validate([0x42, 0x43], against: rule)  // BC
        try RFC_5234.Validator.validate([0x42, 0x44], against: rule)  // BD
    }

    @Test
    func `Repetition of sequence`() throws {
        // *(AB)
        let rule = RFC_5234.Rule(
            name: "test",
            element: .repetition(
                .sequence([
                    .terminal(.byte(0x41)),  // A
                    .terminal(.byte(0x42)),  // B
                ]),
                min: 0,
                max: nil
            )
        )

        try RFC_5234.Validator.validate([], against: rule)  // empty
        try RFC_5234.Validator.validate([0x41, 0x42], against: rule)  // AB
        try RFC_5234.Validator.validate([0x41, 0x42, 0x41, 0x42], against: rule)  // ABAB
    }

    @Test
    func `Optional repetition`() throws {
        // [*A]
        let rule = RFC_5234.Rule(
            name: "test",
            element: .optional(
                .repetition(.terminal(.byte(0x41)), min: 0, max: nil)
            )
        )

        try RFC_5234.Validator.validate([], against: rule)
        try RFC_5234.Validator.validate([0x41, 0x41], against: rule)
    }
}
