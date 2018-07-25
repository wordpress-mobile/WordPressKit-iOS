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
    
    enum DateFormat: String {
        case noTime = "yyyy-mm-dd"
        case dateWithTime = "yyyy-MM-dd HH:mm:ss"
        
        var formatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = rawValue
            return dateFormatter
        }
    }
    
    static var supportMultipleDateFormats: JSONDecoder.DateDecodingStrategy {
        return JSONDecoder.DateDecodingStrategy.custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let len = dateStr.count
            var date: Date? = nil
            if len == DateFormat.noTime.rawValue.count {
                date = DateFormat.noTime.formatter.date(from: dateStr)
            } else if len == DateFormat.dateWithTime.rawValue.count {
                date = DateFormat.dateWithTime.formatter.date(from: dateStr)
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
