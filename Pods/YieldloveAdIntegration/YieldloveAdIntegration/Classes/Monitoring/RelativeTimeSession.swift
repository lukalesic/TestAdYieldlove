import Foundation
import PrebidMobile
import YieldloveExternalConfiguration

public typealias DateGenerator = () -> Date

public protocol TimeSession: Encodable {
    var startingPoint: Date? { get set }
    var dateGenerator: DateGenerator { get }

    func recordEvent(event: TimeEvent) throws
    func start() throws
    func stop() throws
    func getEvent(eventType: String) -> TimeEvent?
}

public class RelativeTimeSession: TimeSession, Encodable {

    public var startingPoint: Date?
    public let dateGenerator: () -> Date

    var events: [TimeEvent] = []
    let sessionId: String
    let adType: MonitoredAdType
    let connection: Connection

    enum CodingKeys: String, CodingKey {
        case adType, connection, events, sessionId
        case startingPoint = "startTime"
    }

    init(adType: MonitoredAdType,
         connection: Connection,
         dateGenerator: @escaping DateGenerator = Date.init,
         uuidGenerator: @escaping () -> UUID = UUID.init) {
        self.adType = adType
        self.connection = connection
        self.dateGenerator = dateGenerator
        self.sessionId = uuidGenerator().uuidString
    }

    public func start() throws {
        if !events.isEmpty {
            throw MonitoringError.multipleCallsToStartSession
        }
        let sessionStarted = dateGenerator()
        let startEvent = MeasuringStarted(startingPoint: sessionStarted)
        self.events.append(startEvent)
        self.startingPoint = sessionStarted
    }

    public func stop() throws {
        if isSessionCompleted() {
            throw MonitoringError.multipleCallsToStopSession
        }
        if let measuringStarted = startingPoint {
            let stopEvent = MeasuringCompleted(measuringStarted: measuringStarted, eventProduced: dateGenerator())
            self.events.append(stopEvent)
        }
    }

    public func recordEvent(event: TimeEvent) throws {
        if events.count == 0 {
            throw MonitoringError.sessionNotStarted
        }
        if isSessionCompleted() {
            throw MonitoringError.addingEventToCompletedSessionNotAllowed
        }
        self.events.append(event)
    }
    
    public func getEvent(eventType: String) -> TimeEvent? {
        return events.first(where: { event in
            event.typeName == eventType
        })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(adType, forKey: .adType)
        try container.encode(connection, forKey: .connection)

        var arrayContainer = container.nestedUnkeyedContainer(forKey: .events)
        for event in events {
            try encodeEvent(into: &arrayContainer, event: event)
        }
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(startingPoint, forKey: .startingPoint)
    }

    private func encodeAs<T: Encodable>(into container: inout UnkeyedEncodingContainer, event: T) throws {
        try container.encode(event)
    }

    private func encodeEvent(into container: inout UnkeyedEncodingContainer, event: TimeEvent) throws {
        if event is MeasuringStarted {
            try encodeAs(into: &container, event: event as? MeasuringStarted)
        } else if event is BidRequested {
            try encodeAs(into: &container, event: event as? BidRequested)
        } else if event is MeasuringCompleted {
            try encodeAs(into: &container, event: event as? MeasuringCompleted)
        } else if event is BidderRespondedSuccessfully {
            try encodeAs(into: &container, event: event as? BidderRespondedSuccessfully)
        } else if event is BidderRespondedWithError {
            try encodeAs(into: &container, event: event as? BidderRespondedWithError)
        } else if event is GamRequested {
            try encodeAs(into: &container, event: event as? GamRequested)
        } else if event is GamRespondedSuccessfully {
            try encodeAs(into: &container, event: event as? GamRespondedSuccessfully)
        } else if event is GamRespondedWithError {
            try encodeAs(into: &container, event: event as? GamRespondedWithError)
        } else if event is AdAnalyzed {
            try encodeAs(into: &container, event: event as? AdAnalyzed)
        } else if event is AdUnitLoaded {
            try encodeAs(into: &container, event: event as? AdUnitLoaded)
        } else {
            throw MonitoringError.unknownEvent
        }
    }
    
    private func isSessionCompleted() -> Bool {
        return events.last?.typeName == "MeasuringCompleted"
    }
}

enum MonitoredAdType: String, Encodable {
    case banner
    case interstitial

    public static func convert(adType: AdType) -> MonitoredAdType {
        if adType == .interstitial {
            return .interstitial
        } else {
            return .banner
        }
    }
}

public enum Connection: String, Encodable {
    case mobile = "MOBILE"
    case wifi = "WIFI"
    case other = "OTHER"
}

public enum BiddingAdapter: String, Encodable {
    case Prebid
    case Criteo
}

public enum BidAdapterResultCode: String, Encodable {
    case SUCCESS
    case NO_BIDS
    case TIMEOUT
    case FAILED
    case NOT_AVAILABLE
    case SKIPPED

    public static func fromPrebidResultCode(code: ResultCode) -> BidAdapterResultCode {
        switch code {
        case .prebidDemandFetchSuccess:
            return .SUCCESS
        case .prebidDemandNoBids:
            return .NO_BIDS
        case .prebidDemandTimedOut:
            return .TIMEOUT
        default:
            return .FAILED
        }
    }
}
