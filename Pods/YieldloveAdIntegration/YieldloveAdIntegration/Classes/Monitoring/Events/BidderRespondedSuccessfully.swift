import Foundation

class BidderRespondedSuccessfully: TimeEvent {
    var resultCode: BidAdapterResultCode
    var bidAdapter: BiddingAdapter

    class BidderRespondedSuccessfullyCodingKeys: TimeEvent.TimeEventCodingKeys {
        public static let resultCode = TimeEventCodingKeys(stringValue: "resultCode")
        public static let bidder = TimeEventCodingKeys(jsonKey: "bidder", rawValue: "bidAdapter")
    }

    init(measuringStarted: Date, eventProduced: Date,
         adapter: BiddingAdapter, result: BidAdapterResultCode) {
        self.bidAdapter = adapter
        self.resultCode = result
        super.init(measuringStarted: measuringStarted, eventProduced: eventProduced)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = try self.encodeTimeEventData(to: encoder)
        try container.encode(bidAdapter, forKey: BidderRespondedSuccessfullyCodingKeys.bidder)
        try container.encode(resultCode, forKey: BidderRespondedSuccessfullyCodingKeys.resultCode)
    }
}
