import Foundation

class SessionEncoder {
    
    let encoder: JSONEncoder
    
    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            let milliseconds = Int(date.timeIntervalSince1970.milliseconds)
            var singleValueEnc = encoder.singleValueContainer()
            try singleValueEnc.encode(milliseconds)
        })
    }
    
    func encode<T: Encodable>(_ object: T) throws -> Data {
        return try encoder.encode(object)
    }
}
