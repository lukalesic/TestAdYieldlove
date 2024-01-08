import Foundation

class CodingKeys: CodingKey {
    var intValue: Int?
    var rawValue: String
    typealias RawValue = String
    var stringValue: String

    required init(stringValue: String) {
        self.stringValue = stringValue
        self.rawValue = stringValue
    }

    init(jsonKey stringValue: String, rawValue: String) {
        self.stringValue = stringValue
        self.rawValue = rawValue
    }

    required init?(intValue: Int) {
        nil
    }
}
