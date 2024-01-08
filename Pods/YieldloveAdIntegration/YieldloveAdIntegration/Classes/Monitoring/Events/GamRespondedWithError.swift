import Foundation

class GamRespondedWithError: TimeEvent {

    class GamRespondedWithErrorCodingKeys: TimeEvent.TimeEventCodingKeys {
        public static let error = TimeEventCodingKeys(stringValue: "error")
    }

    var error: GamError

    init(measuringStarted: Date, eventProduced: Date, error: Error) {
        self.error = GamError(message: error.localizedDescription, type: "GamRespondedWithError", stackTrace: "")
        super.init(measuringStarted: measuringStarted, eventProduced: eventProduced)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = try self.encodeTimeEventData(to: encoder)
        try container.encode(error, forKey: GamRespondedWithErrorCodingKeys.error)
    }
}

struct GamError: Encodable {
    var message: String
    var type: String
    var stackTrace: String
}
