import Foundation

class BidRequested: TimeEvent {

    var bidAdapter: BiddingAdapter

    class BidRequestedCodingKeys: TimeEvent.TimeEventCodingKeys {
        public static let bidder = TimeEventCodingKeys(jsonKey: "bidder", rawValue: "bidAdapter")
    }
    
    init(measuringStarted: Date, eventProduced: Date, bidAdapter: BiddingAdapter) {
        self.bidAdapter = bidAdapter
        super.init(measuringStarted: measuringStarted, eventProduced: eventProduced)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = try self.encodeTimeEventData(to: encoder)
        try container.encode(bidAdapter, forKey: BidRequestedCodingKeys.bidder)
    }
    
}
