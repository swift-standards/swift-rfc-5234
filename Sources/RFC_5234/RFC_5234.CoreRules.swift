// RFC_5234.CoreRules.swift
// swift-rfc-5234
//
// RFC 5234 Appendix B.1 Core Rules
//
// These core rules delegate to INCITS-4-1986 for character classification
// rather than reimplementing ASCII character classes.

import INCITS_4_1986

extension RFC_5234 {
    /// Core ABNF rules defined in RFC 5234 Appendix B.1
    ///
    /// These are the fundamental rules used by most ABNF specifications.
    /// They define common character classes and whitespace patterns.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Use predefined core rules
    /// let digitRule = RFC_5234.CoreRules.digit
    /// let alphaRule = RFC_5234.CoreRules.alpha
    ///
    /// // Validate input
    /// try RFC_5234.Validator.validate([0x35], against: digitRule)  // "5" ✓
    /// ```
    ///
    /// ## Core Rules
    ///
    /// - `ALPHA`: A-Z / a-z
    /// - `DIGIT`: 0-9
    /// - `HEXDIG`: 0-9 / A-F / a-f
    /// - `BIT`: "0" / "1"
    /// - `SP`: Space (0x20)
    /// - `HTAB`: Horizontal tab (0x09)
    /// - `CR`: Carriage return (0x0D)
    /// - `LF`: Linefeed (0x0A)
    /// - `CRLF`: CR LF (internet newline)
    /// - `WSP`: SP / HTAB (whitespace)
    /// - `DQUOTE`: Double quote (0x22)
    /// - `VCHAR`: Visible characters (0x21-0x7E)
    /// - `CHAR`: Any 7-bit ASCII except NUL (0x01-0x7F)
    /// - `CTL`: Control characters (0x00-0x1F / 0x7F)
    /// - `OCTET`: Any 8-bit value (0x00-0xFF)
    public enum CoreRules {}
}

// MARK: - Character Class Rules

extension RFC_5234.CoreRules {
    /// ALPHA = %x41-5A / %x61-7A  ; A-Z / a-z
    ///
    /// Matches any ASCII alphabetic character (upper or lowercase).
    ///
    /// Equivalent to INCITS_4_1986.CharacterClassification.isLetter(_:)
    public static let alpha = RFC_5234.Rule(
        name: "ALPHA",
        element: .alternation([
            .terminal(.byteRange(0x41, 0x5A)),  // A-Z
            .terminal(.byteRange(0x61, 0x7A))   // a-z
        ])
    )

    /// DIGIT = %x30-39  ; 0-9
    ///
    /// Matches any ASCII digit.
    ///
    /// Equivalent to INCITS_4_1986.CharacterClassification.isDigit(_:)
    public static let digit = RFC_5234.Rule(
        name: "DIGIT",
        element: .terminal(.byteRange(0x30, 0x39))
    )

    /// HEXDIG = DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
    ///
    /// Matches any hexadecimal digit (0-9, A-F).
    /// Note: Case-insensitive, so also matches a-f.
    ///
    /// Equivalent to INCITS_4_1986.CharacterClassification.isHexDigit(_:)
    public static let hexdig = RFC_5234.Rule(
        name: "HEXDIG",
        element: .alternation([
            .terminal(.byteRange(0x30, 0x39)),  // 0-9
            .terminal(.string("A")),
            .terminal(.string("B")),
            .terminal(.string("C")),
            .terminal(.string("D")),
            .terminal(.string("E")),
            .terminal(.string("F"))
        ])
    )

    /// BIT = "0" / "1"
    ///
    /// Matches a binary digit.
    public static let bit = RFC_5234.Rule(
        name: "BIT",
        element: .alternation([
            .terminal(.byte(0x30)),  // "0"
            .terminal(.byte(0x31))   // "1"
        ])
    )
}

// MARK: - Whitespace Rules

extension RFC_5234.CoreRules {
    /// SP = %x20  ; space
    ///
    /// Matches a space character.
    /// Uses INCITS-4-1986 SPACE.sp constant.
    public static let sp = RFC_5234.Rule(
        name: "SP",
        element: .terminal(.byte(INCITS_4_1986.SPACE.sp))
    )

    /// HTAB = %x09  ; horizontal tab
    ///
    /// Matches a horizontal tab character.
    /// Uses INCITS-4-1986 ControlCharacters.htab constant.
    public static let htab = RFC_5234.Rule(
        name: "HTAB",
        element: .terminal(.byte(INCITS_4_1986.ControlCharacters.htab))
    )

    /// CR = %x0D  ; carriage return
    ///
    /// Matches a carriage return character.
    /// Uses INCITS-4-1986 ControlCharacters.cr constant.
    public static let cr = RFC_5234.Rule(
        name: "CR",
        element: .terminal(.byte(INCITS_4_1986.ControlCharacters.cr))
    )

    /// LF = %x0A  ; linefeed
    ///
    /// Matches a linefeed character.
    /// Uses INCITS-4-1986 ControlCharacters.lf constant.
    public static let lf = RFC_5234.Rule(
        name: "LF",
        element: .terminal(.byte(INCITS_4_1986.ControlCharacters.lf))
    )

    /// CRLF = CR LF  ; Internet newline
    ///
    /// Matches the standard internet newline sequence.
    /// Uses INCITS-4-1986 ControlCharacters.crlf constant.
    public static let crlf = RFC_5234.Rule(
        name: "CRLF",
        element: .sequence([
            .terminal(.byte(INCITS_4_1986.ControlCharacters.cr)),
            .terminal(.byte(INCITS_4_1986.ControlCharacters.lf))
        ])
    )

    /// WSP = SP / HTAB  ; whitespace
    ///
    /// Matches either a space or horizontal tab.
    /// Note: INCITS whitespace includes CR/LF, but RFC 5234 WSP is only SP/HTAB.
    public static let wsp = RFC_5234.Rule(
        name: "WSP",
        element: .alternation([
            .terminal(.byte(INCITS_4_1986.SPACE.sp)),
            .terminal(.byte(INCITS_4_1986.ControlCharacters.htab))
        ])
    )
}

// MARK: - Punctuation Rules

extension RFC_5234.CoreRules {
    /// DQUOTE = %x22  ; " (double quote)
    ///
    /// Matches a double quote character.
    /// Uses INCITS-4-1986 GraphicCharacters.quotationMark constant.
    public static let dquote = RFC_5234.Rule(
        name: "DQUOTE",
        element: .terminal(.byte(INCITS_4_1986.GraphicCharacters.quotationMark))
    )
}

// MARK: - Character Range Rules

extension RFC_5234.CoreRules {
    /// VCHAR = %x21-7E  ; visible (printing) characters
    ///
    /// Matches any visible ASCII character.
    ///
    /// Equivalent to INCITS_4_1986.CharacterClassification.isVisible(_:)
    public static let vchar = RFC_5234.Rule(
        name: "VCHAR",
        element: .terminal(.byteRange(0x21, 0x7E))
    )

    /// CHAR = %x01-7F  ; any 7-bit ASCII character, excluding NUL
    ///
    /// Matches any 7-bit ASCII character except NUL (0x00).
    ///
    /// Note: INCITS-4-1986 doesn't define CHAR, but it's equivalent to:
    /// `byte != 0 && byte < 0x80`
    public static let char = RFC_5234.Rule(
        name: "CHAR",
        element: .terminal(.byteRange(0x01, 0x7F))
    )

    /// CTL = %x00-1F / %x7F  ; controls
    ///
    /// Matches any ASCII control character.
    ///
    /// Equivalent to INCITS_4_1986.CharacterClassification.isControl(_:)
    public static let ctl = RFC_5234.Rule(
        name: "CTL",
        element: .alternation([
            .terminal(.byteRange(0x00, 0x1F)),
            .terminal(.byte(0x7F))
        ])
    )

    /// OCTET = %x00-FF  ; 8 bits of data
    ///
    /// Matches any byte value.
    ///
    /// Note: Any UInt8 is a valid OCTET.
    public static let octet = RFC_5234.Rule(
        name: "OCTET",
        element: .terminal(.byteRange(0x00, 0xFF))
    )
}

// MARK: - Convenience Collections

extension RFC_5234.CoreRules {
    /// All core rules as a dictionary keyed by name
    ///
    /// Useful for rule lookup by name.
    public static let all: [String: RFC_5234.Rule] = [
        "ALPHA": alpha,
        "DIGIT": digit,
        "HEXDIG": hexdig,
        "BIT": bit,
        "SP": sp,
        "HTAB": htab,
        "CR": cr,
        "LF": lf,
        "CRLF": crlf,
        "WSP": wsp,
        "DQUOTE": dquote,
        "VCHAR": vchar,
        "CHAR": char,
        "CTL": ctl,
        "OCTET": octet
    ]
}
