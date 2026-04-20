// CoreRules Tests.swift
// swift-rfc-5234
//
// Tests for RFC_5234.CoreRules

import RFC_5234
import Testing

@Suite("RFC_5234.CoreRules - Character Classes")
struct CoreRulesCharacterClassTests {
    @Test
    func `ALPHA matches uppercase letters`() throws {
        for byte in UInt8(0x41)...UInt8(0x5A) {  // A-Z
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.alpha)
        }
    }

    @Test
    func `ALPHA matches lowercase letters`() throws {
        for byte in UInt8(0x61)...UInt8(0x7A) {  // a-z
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.alpha)
        }
    }

    @Test
    func `ALPHA rejects digits`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x30], against: RFC_5234.CoreRules.alpha)  // "0"
        }
    }

    @Test
    func `DIGIT matches 0-9`() throws {
        for byte in UInt8(0x30)...UInt8(0x39) {  // 0-9
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.digit)
        }
    }

    @Test
    func `DIGIT rejects letters`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.digit)  // "A"
        }
    }

    @Test
    func `HEXDIG matches 0-9`() throws {
        for byte in UInt8(0x30)...UInt8(0x39) {  // 0-9
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test
    func `HEXDIG matches A-F (uppercase)`() throws {
        for char in ["A", "B", "C", "D", "E", "F"] {
            try RFC_5234.Validator.validate(Array(char.utf8), against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test
    func `HEXDIG matches a-f (lowercase, case-insensitive)`() throws {
        for char in ["a", "b", "c", "d", "e", "f"] {
            try RFC_5234.Validator.validate(Array(char.utf8), against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test
    func `HEXDIG rejects G`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x47], against: RFC_5234.CoreRules.hexdig)  // "G"
        }
    }

    @Test
    func `BIT matches 0 and 1`() throws {
        try RFC_5234.Validator.validate([0x30], against: RFC_5234.CoreRules.bit)  // "0"
        try RFC_5234.Validator.validate([0x31], against: RFC_5234.CoreRules.bit)  // "1"
    }

    @Test
    func `BIT rejects 2`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x32], against: RFC_5234.CoreRules.bit)  // "2"
        }
    }
}

@Suite("RFC_5234.CoreRules - Whitespace")
struct CoreRulesWhitespaceTests {
    @Test
    func `SP matches space`() throws {
        try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.sp)
    }

    @Test
    func `SP rejects tab`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.sp)
        }
    }

    @Test
    func `HTAB matches tab`() throws {
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.htab)
    }

    @Test
    func `CR matches carriage return`() throws {
        try RFC_5234.Validator.validate([0x0D], against: RFC_5234.CoreRules.cr)
    }

    @Test
    func `LF matches linefeed`() throws {
        try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.lf)
    }

    @Test
    func `CRLF matches CR LF sequence`() throws {
        try RFC_5234.Validator.validate([0x0D, 0x0A], against: RFC_5234.CoreRules.crlf)
    }

    @Test
    func `CRLF rejects just CR`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0D], against: RFC_5234.CoreRules.crlf)
        }
    }

    @Test
    func `CRLF rejects just LF`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.crlf)
        }
    }

    @Test
    func `WSP matches space`() throws {
        try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.wsp)
    }

    @Test
    func `WSP matches tab`() throws {
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.wsp)
    }

    @Test
    func `WSP rejects other whitespace`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.wsp)  // LF
        }
    }
}

@Suite("RFC_5234.CoreRules - Punctuation")
struct CoreRulesPunctuationTests {
    @Test
    func `DQUOTE matches double quote`() throws {
        try RFC_5234.Validator.validate([0x22], against: RFC_5234.CoreRules.dquote)
    }

    @Test
    func `DQUOTE rejects single quote`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x27], against: RFC_5234.CoreRules.dquote)
        }
    }
}

@Suite("RFC_5234.CoreRules - Character Ranges")
struct CoreRulesCharacterRangeTests {
    @Test
    func `VCHAR matches visible characters`() throws {
        // Test first, middle, and last
        try RFC_5234.Validator.validate([0x21], against: RFC_5234.CoreRules.vchar)  // !
        try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.vchar)  // A
        try RFC_5234.Validator.validate([0x7E], against: RFC_5234.CoreRules.vchar)  // ~
    }

    @Test
    func `VCHAR rejects space`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.vchar)
        }
    }

    @Test
    func `VCHAR rejects control characters`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.vchar)
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x1F], against: RFC_5234.CoreRules.vchar)
        }
    }

    @Test
    func `CHAR matches 7-bit ASCII (excluding NUL)`() throws {
        try RFC_5234.Validator.validate([0x01], against: RFC_5234.CoreRules.char)
        try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.char)  // A
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.char)
    }

    @Test
    func `CHAR rejects NUL`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.char)
        }
    }

    @Test
    func `CHAR rejects 8-bit values`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x80], against: RFC_5234.CoreRules.char)
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0xFF], against: RFC_5234.CoreRules.char)
        }
    }

    @Test
    func `CTL matches control characters`() throws {
        try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.ctl)  // NUL
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.ctl)  // TAB
        try RFC_5234.Validator.validate([0x1F], against: RFC_5234.CoreRules.ctl)
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.ctl)  // DEL
    }

    @Test
    func `CTL rejects printable characters`() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.ctl)  // space
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.ctl)  // A
        }
    }

    @Test
    func `OCTET matches all byte values`() throws {
        try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0x80], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0xFF], against: RFC_5234.CoreRules.octet)
    }
}

@Suite("RFC_5234.CoreRules - Lookup")
struct CoreRulesLookupTests {
    @Test
    func `All core rules are in lookup dictionary`() {
        let expectedNames = [
            "ALPHA", "DIGIT", "HEXDIG", "BIT",
            "SP", "HTAB", "CR", "LF", "CRLF", "WSP",
            "DQUOTE",
            "VCHAR", "CHAR", "CTL", "OCTET",
        ]

        for name in expectedNames {
            #expect(RFC_5234.CoreRules.all[name] != nil, "Missing core rule: \(name)")
        }
    }

    @Test
    func `Lookup by name works`() throws {
        let digit = RFC_5234.CoreRules.all["DIGIT"]!
        try RFC_5234.Validator.validate([0x35], against: digit)  // "5"
    }
}
