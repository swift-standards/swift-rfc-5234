import RFC_5234
import StandardsTestSupport
import Testing

@Suite("RFC 5234 Basic Tests")
struct BasicTests {
    @Test("Case-insensitive string matching")
    func caseInsensitiveString() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.string("abc"))
        )

        // Should match various cases
        try RFC_5234.Validator.validate([0x61, 0x62, 0x63], against: rule)  // "abc"
        try RFC_5234.Validator.validate([0x41, 0x42, 0x43], against: rule)  // "ABC"
        try RFC_5234.Validator.validate([0x41, 0x62, 0x43], against: rule)  // "AbC"
    }

    @Test("Byte value matching")
    func byteValue() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.byte(0x41))  // 'A'
        )

        try RFC_5234.Validator.validate([0x41], against: rule)
    }

    @Test("Byte range matching")
    func byteRange() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.byteRange(0x41, 0x5A))  // 'A'-'Z'
        )

        try RFC_5234.Validator.validate([0x41], against: rule)  // 'A'
        try RFC_5234.Validator.validate([0x5A], against: rule)  // 'Z'
        try RFC_5234.Validator.validate([0x4D], against: rule)  // 'M'
    }
}
