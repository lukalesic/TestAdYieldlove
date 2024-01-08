import Foundation

struct BidderError: Encodable {
    var message: String
    var type: StringLiteralType
    var stackTrace: String
}

class BidderRespondedWithError: TimeEvent {

    var error: BidderError
    var bidAdapter: BiddingAdapter

    class BidderRespondedWithErrorCodingKeys: TimeEvent.TimeEventCodingKeys {
        public static let error = TimeEventCodingKeys(stringValue: "error")
        public static let bidder = TimeEventCodingKeys(jsonKey: "bidder", rawValue: "bidAdapter")
    }

    init(measuringStarted: Date, eventProduced: Date,
         adapter: BiddingAdapter, error: Error) {
        self.bidAdapter = adapter
        self.error = BidderError(message: error.localizedDescription, type: "BidderError", stackTrace: "")
        super.init(measuringStarted: measuringStarted, eventProduced: eventProduced)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = try self.encodeTimeEventData(to: encoder)
        try container.encode(bidAdapter, forKey: BidderRespondedWithErrorCodingKeys.bidder)
        try container.encode(error, forKey: BidderRespondedWithErrorCodingKeys.error)
    }
}
