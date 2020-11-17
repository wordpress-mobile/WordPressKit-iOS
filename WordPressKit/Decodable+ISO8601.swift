/// Stub to represent the date format type in the decoder
struct ISO8601Date { }

extension KeyedDecodingContainer {
    func decode(_ type: ISO8601Date.Type, forKey key: K) throws -> Date {
        let value = try self.decode(String.self, forKey: key)
        guard let date = Date.dateWithISO8601WithMillisecondsString(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date format was not parsable")
            throw DecodingError.dataCorrupted(context)
        }
        return date
    }
}
