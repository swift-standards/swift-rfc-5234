import INCITS_4_1986

extension RFC_5234 {
    /// A terminal element in an ABNF grammar.
    ///
    /// Terminals represent the actual matching patterns in ABNF rules.
    /// RFC 5234 defines terminals for:
    /// - Literal text strings (case-insensitive by default)
    /// - Numeric values (byte ranges)
    /// - Character ranges
    public struct Terminal: Hashable, Sendable {
        private let matcher: Matcher

        private enum Matcher: Hashable, Sendable {
            case string(String, caseSensitive: Bool)
            case byteValue(UInt8)
            case byteRange(UInt8, UInt8)
        }

        private init(matcher: Matcher) {
            self.matcher = matcher
        }

        /// Creates a case-insensitive string literal terminal.
        ///
        /// In RFC 5234, string literals are case-insensitive by default.
        /// For example, "abc" matches "abc", "Abc", "ABC", etc.
        ///
        /// - Parameter string: The string to match (case-insensitive)
        public static func string(_ string: String) -> Self {
            Self(matcher: .string(string, caseSensitive: false))
        }

        /// Creates a case-sensitive string literal terminal.
        ///
        /// This method enables RFC 7405 %s"..." syntax for exact string matching.
        /// Unlike the default case-insensitive matching, this matches only the exact case.
        ///
        /// - Parameter string: The string to match (case-sensitive)
        public static func caseSensitiveString(_ string: String) -> Self {
            Self(matcher: .string(string, caseSensitive: true))
        }

        /// Creates a terminal that matches a specific byte value.
        ///
        /// - Parameter byte: The byte value to match
        public static func byte(_ byte: UInt8) -> Self {
            Self(matcher: .byteValue(byte))
        }

        /// Creates a terminal that matches a range of byte values.
        ///
        /// - Parameters:
        ///   - lower: The lower bound (inclusive)
        ///   - upper: The upper bound (inclusive)
        public static func byteRange(_ lower: UInt8, _ upper: UInt8) -> Self {
            Self(matcher: .byteRange(lower, upper))
        }

        /// Validates whether the given bytes match this terminal.
        ///
        /// - Parameter bytes: The bytes to validate
        /// - Returns: `true` if the bytes match, `false` otherwise
        public func matches(_ bytes: [UInt8]) -> Bool {
            switch matcher {
            case let .string(string, caseSensitive):
                let stringBytes = Array(string.utf8)
                guard bytes.count == stringBytes.count else { return false }
                if caseSensitive {
                    return bytes == stringBytes
                } else {
                    return zip(bytes, stringBytes).allSatisfy { byte, expected in
                        let lower = INCITS_4_1986.CaseConversion.convert(byte, to: .lower)
                        let expectedLower = INCITS_4_1986.CaseConversion.convert(expected, to: .lower)
                        return lower == expectedLower
                    }
                }

            case let .byteValue(value):
                return bytes.count == 1 && bytes[0] == value

            case let .byteRange(lower, upper):
                return bytes.count == 1 && bytes[0] >= lower && bytes[0] <= upper
            }
        }
    }
}
