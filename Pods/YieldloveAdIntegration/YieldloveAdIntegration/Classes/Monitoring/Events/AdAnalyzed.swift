import Foundation

class AdAnalyzed: TimeEvent {
    var winner: String
    
    class AdAnalyzedCodingKeys: TimeEvent.TimeEventCodingKeys {
        public static let winner = TimeEventCodingKeys(stringValue: "winner")
    }
    
    init(measuringStarted: Date, eventProduced: Date, winner: String) {
        self.winner = winner
        super.init(measuringStarted: measuringStarted, eventProduced: eventProduced)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = try self.encodeTimeEventData(to: encoder)
        try container.encode(winner, forKey: AdAnalyzedCodingKeys.winner)
    }
}
