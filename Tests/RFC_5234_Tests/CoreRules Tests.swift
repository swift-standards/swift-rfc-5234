// CoreRules Tests.swift
// swift-rfc-5234
//
// Tests for RFC_5234.CoreRules

import RFC_5234
import Testing

@Suite("RFC_5234.CoreRules - Character Classes")
struct CoreRulesCharacterClassTests {
    @Test("ALPHA matches uppercase letters")
    func alphaUppercase() throws {
        for byte in UInt8(0x41)...UInt8(0x5A) {  // A-Z
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.alpha)
        }
    }

    @Test("ALPHA matches lowercase letters")
    func alphaLowercase() throws {
        for byte in UInt8(0x61)...UInt8(0x7A) {  // a-z
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.alpha)
        }
    }

    @Test("ALPHA rejects digits")
    func alphaRejectsDigits() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x30], against: RFC_5234.CoreRules.alpha)  // "0"
        }
    }

    @Test("DIGIT matches 0-9")
    func digitMatches() throws {
        for byte in UInt8(0x30)...UInt8(0x39) {  // 0-9
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.digit)
        }
    }

    @Test("DIGIT rejects letters")
    func digitRejectsLetters() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.digit)  // "A"
        }
    }

    @Test("HEXDIG matches 0-9")
    func hexdigDigits() throws {
        for byte in UInt8(0x30)...UInt8(0x39) {  // 0-9
            try RFC_5234.Validator.validate([byte], against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test("HEXDIG matches A-F (uppercase)")
    func hexdigUppercase() throws {
        for char in ["A", "B", "C", "D", "E", "F"] {
            try RFC_5234.Validator.validate(Array(char.utf8), against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test("HEXDIG matches a-f (lowercase, case-insensitive)")
    func hexdigLowercase() throws {
        for char in ["a", "b", "c", "d", "e", "f"] {
            try RFC_5234.Validator.validate(Array(char.utf8), against: RFC_5234.CoreRules.hexdig)
        }
    }

    @Test("HEXDIG rejects G")
    func hexdigRejectsG() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x47], against: RFC_5234.CoreRules.hexdig)  // "G"
        }
    }

    @Test("BIT matches 0 and 1")
    func bitMatches() throws {
        try RFC_5234.Validator.validate([0x30], against: RFC_5234.CoreRules.bit)  // "0"
        try RFC_5234.Validator.validate([0x31], against: RFC_5234.CoreRules.bit)  // "1"
    }

    @Test("BIT rejects 2")
    func bitRejects2() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x32], against: RFC_5234.CoreRules.bit)  // "2"
        }
    }
}

@Suite("RFC_5234.CoreRules - Whitespace")
struct CoreRulesWhitespaceTests {
    @Test("SP matches space")
    func spMatches() throws {
        try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.sp)
    }

    @Test("SP rejects tab")
    func spRejectsTab() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.sp)
        }
    }

    @Test("HTAB matches tab")
    func htabMatches() throws {
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.htab)
    }

    @Test("CR matches carriage return")
    func crMatches() throws {
        try RFC_5234.Validator.validate([0x0D], against: RFC_5234.CoreRules.cr)
    }

    @Test("LF matches linefeed")
    func lfMatches() throws {
        try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.lf)
    }

    @Test("CRLF matches CR LF sequence")
    func crlfMatches() throws {
        try RFC_5234.Validator.validate([0x0D, 0x0A], against: RFC_5234.CoreRules.crlf)
    }

    @Test("CRLF rejects just CR")
    func crlfRejectsCR() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0D], against: RFC_5234.CoreRules.crlf)
        }
    }

    @Test("CRLF rejects just LF")
    func crlfRejectsLF() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.crlf)
        }
    }

    @Test("WSP matches space")
    func wspMatchesSpace() throws {
        try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.wsp)
    }

    @Test("WSP matches tab")
    func wspMatchesTab() throws {
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.wsp)
    }

    @Test("WSP rejects other whitespace")
    func wspRejectsOther() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x0A], against: RFC_5234.CoreRules.wsp)  // LF
        }
    }
}

@Suite("RFC_5234.CoreRules - Punctuation")
struct CoreRulesPunctuationTests {
    @Test("DQUOTE matches double quote")
    func dquoteMatches() throws {
        try RFC_5234.Validator.validate([0x22], against: RFC_5234.CoreRules.dquote)
    }

    @Test("DQUOTE rejects single quote")
    func dquoteRejectsSingleQuote() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x27], against: RFC_5234.CoreRules.dquote)
        }
    }
}

@Suite("RFC_5234.CoreRules - Character Ranges")
struct CoreRulesCharacterRangeTests {
    @Test("VCHAR matches visible characters")
    func vcharMatches() throws {
        // Test first, middle, and last
        try RFC_5234.Validator.validate([0x21], against: RFC_5234.CoreRules.vchar)  // !
        try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.vchar)  // A
        try RFC_5234.Validator.validate([0x7E], against: RFC_5234.CoreRules.vchar)  // ~
    }

    @Test("VCHAR rejects space")
    func vcharRejectsSpace() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.vchar)
        }
    }

    @Test("VCHAR rejects control characters")
    func vcharRejectsControl() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.vchar)
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x1F], against: RFC_5234.CoreRules.vchar)
        }
    }

    @Test("CHAR matches 7-bit ASCII (excluding NUL)")
    func charMatches() throws {
        try RFC_5234.Validator.validate([0x01], against: RFC_5234.CoreRules.char)
        try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.char)  // A
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.char)
    }

    @Test("CHAR rejects NUL")
    func charRejectsNUL() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.char)
        }
    }

    @Test("CHAR rejects 8-bit values")
    func charRejects8Bit() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x80], against: RFC_5234.CoreRules.char)
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0xFF], against: RFC_5234.CoreRules.char)
        }
    }

    @Test("CTL matches control characters")
    func ctlMatches() throws {
        try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.ctl)  // NUL
        try RFC_5234.Validator.validate([0x09], against: RFC_5234.CoreRules.ctl)  // TAB
        try RFC_5234.Validator.validate([0x1F], against: RFC_5234.CoreRules.ctl)
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.ctl)  // DEL
    }

    @Test("CTL rejects printable characters")
    func ctlRejectsPrintable() {
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x20], against: RFC_5234.CoreRules.ctl)  // space
        }
        #expect(throws: RFC_5234.Validator.Error.self) {
            try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.ctl)  // A
        }
    }

    @Test("OCTET matches all byte values")
    func octetMatches() throws {
        try RFC_5234.Validator.validate([0x00], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0x7F], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0x80], against: RFC_5234.CoreRules.octet)
        try RFC_5234.Validator.validate([0xFF], against: RFC_5234.CoreRules.octet)
    }
}

@Suite("RFC_5234.CoreRules - Lookup")
struct CoreRulesLookupTests {
    @Test("All core rules are in lookup dictionary")
    func allRulesPresent() {
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

    @Test("Lookup by name works")
    func lookupByName() throws {
        let digit = RFC_5234.CoreRules.all["DIGIT"]!
        try RFC_5234.Validator.validate([0x35], against: digit)  // "5"
    }
}
