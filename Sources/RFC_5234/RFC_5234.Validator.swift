extension RFC_5234 {
    /// Validates input against ABNF rules.
    public enum Validator {
        /// Validates whether the given bytes match the rule.
        ///
        /// - Parameters:
        ///   - bytes: The bytes to validate
        ///   - rule: The ABNF rule to validate against
        /// - Throws: `ValidationError` if validation fails
        public static func validate(
            _ bytes: [UInt8],
            against rule: Rule
        ) throws {
            let (matched, consumed) = try matchElement(rule.element, in: bytes, at: 0)
            guard matched else {
                throw Error.doesNotMatch(rule.name)
            }
            guard consumed == bytes.count else {
                throw Error.incompleteMatch(
                    rule.name,
                    consumed: consumed,
                    total: bytes.count
                )
            }
        }

        private static func matchElement(
            _ element: Element,
            in bytes: [UInt8],
            at offset: Int
        ) throws -> (matched: Bool, consumed: Int) {
            switch element {
            case .terminal(let terminal):
                // Try to match the terminal at the current position
                var length = 1
                while offset + length <= bytes.count {
                    let slice = Array(bytes[offset..<(offset + length)])
                    if terminal.matches(slice) {
                        return (true, length)
                    }
                    length += 1
                    if length > 100 { break }  // Prevent infinite loops
                }
                return (false, 0)

            case .sequence(let elements):
                var totalConsumed = 0
                for elem in elements {
                    let (matched, consumed) = try matchElement(
                        elem,
                        in: bytes,
                        at: offset + totalConsumed
                    )
                    guard matched else { return (false, 0) }
                    totalConsumed += consumed
                }
                return (true, totalConsumed)

            case .alternation(let elements):
                for elem in elements {
                    let (matched, consumed) = try matchElement(elem, in: bytes, at: offset)
                    if matched {
                        return (true, consumed)
                    }
                }
                return (false, 0)

            case .optional(let elem):
                let (matched, consumed) = try matchElement(elem, in: bytes, at: offset)
                return (true, matched ? consumed : 0)

            case .repetition(let elem, let min, let max):
                var count = 0
                var totalConsumed = 0
                while true {
                    if let max, count >= max { break }
                    let (matched, consumed) = try matchElement(
                        elem,
                        in: bytes,
                        at: offset + totalConsumed
                    )
                    if !matched { break }
                    count += 1
                    totalConsumed += consumed
                    if offset + totalConsumed >= bytes.count { break }
                }
                return (count >= min, totalConsumed)

            case .ruleReference:
                throw Error.unsupportedFeature("Rule references not yet implemented")
            }
        }

        /// Errors that can occur during validation.
        public enum Error: Swift.Error, Sendable, Equatable {
            case doesNotMatch(String)
            case incompleteMatch(String, consumed: Int, total: Int)
            case unsupportedFeature(String)
        }

        /// Deprecated: Use `Error` instead
        @available(*, deprecated, renamed: "Error")
        public typealias ValidationError = Error
    }
}

extension RFC_5234.Validator.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .doesNotMatch(let ruleName):
            return "Input does not match rule '\(ruleName)'"
        case .incompleteMatch(let ruleName, let consumed, let total):
            return "Incomplete match for rule '\(ruleName)': consumed \(consumed) of \(total) bytes"
        case .unsupportedFeature(let feature):
            return "Unsupported feature: \(feature)"
        }
    }
}
