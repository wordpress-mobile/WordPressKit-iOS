import Foundation

extension JSONDecoder {

    static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.supportMultipleDateFormats
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

extension JSONDecoder.DateDecodingStrategy {
    
    static var supportMultipleDateFormats: JSONDecoder.DateDecodingStrategy {
        return JSONDecoder.DateDecodingStrategy.custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let dateNoTimeFormatter = DateFormatter()
            dateNoTimeFormatter.dateFormat = "yyyy-mm-dd"
            
            let dateWithTimeFormatter = DateFormatter()
            dateWithTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let len = dateStr.count
            var date: Date? = nil
            if len == 10 {
                date = dateNoTimeFormatter.date(from: dateStr)
            } else if len == 19 {
                date = dateWithTimeFormatter.date(from: dateStr)
            }
            guard let _date = date else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateStr)"
                )
            }
            return _date
        })
    }
}
