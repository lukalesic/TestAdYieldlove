import YieldloveExternalConfiguration

typealias EventProducer = (_ measuringStarted: Date) -> TimeEvent

protocol TimeEventRecorder {
    var session: TimeSession { get }
    func startSession()
    func stopSession()
    func recordAdUnitLoaded()
    func recordRequestBids(bidAdapter: BiddingAdapter)
    func recordBidderRespondedSuccessfully(bidAdapter: BiddingAdapter, resultCode: BidAdapterResultCode)
    func recordGamRequested()
    func recordGamRespondedSuccessfully()
    func recordGamRespondedWithError(error: Error)
    func recordAdAnalyzed(winner: String)
}

class YLTimeEventRecorder: TimeEventRecorder {
    
    let session: TimeSession
    private let debug: Bool
    
    init(adType: AdType, connection: Connection) {
        let type = MonitoredAdType.convert(adType: adType)
        self.session = RelativeTimeSession(adType: type, connection: connection)
        self.debug = Yieldlove.instance.debug
    }
    
    func startSession() {
        do {
            try session.start()
        } catch {
            debugPrint(error)
        }
    }
    
    func stopSession() {
        do {
            try session.stop()
        } catch {
            debugPrint(error)
        }
    }
    
    func recordAdUnitLoaded() {
        produceAndRecordEvent {
            AdUnitLoaded(measuringStarted: $0, eventProduced: session.dateGenerator())
        }
    }
    
    func recordRequestBids(bidAdapter: BiddingAdapter) {
        produceAndRecordEvent {
            BidRequested(measuringStarted: $0, eventProduced: session.dateGenerator(), bidAdapter: bidAdapter)
        }
    }
    
    func recordBidderRespondedSuccessfully(bidAdapter: BiddingAdapter, resultCode: BidAdapterResultCode) {
        produceAndRecordEvent {
            BidderRespondedSuccessfully(
                measuringStarted: $0,
                eventProduced: session.dateGenerator(),
                adapter: bidAdapter,
                result: resultCode)
        }
    }
    
    func recordGamRequested() {
        produceAndRecordEvent {
            GamRequested(measuringStarted: $0, eventProduced: session.dateGenerator())
        }
    }
    
    func recordGamRespondedSuccessfully() {
        produceAndRecordEvent {
            GamRespondedSuccessfully(measuringStarted: $0, eventProduced: session.dateGenerator())
        }
    }
    
    func recordGamRespondedWithError(error: Error) {
        produceAndRecordEvent {
            GamRespondedWithError(measuringStarted: $0, eventProduced: session.dateGenerator(), error: error)
        }
    }
    
    func recordAdAnalyzed(winner: String) {
        produceAndRecordEvent {
            AdAnalyzed(measuringStarted: $0, eventProduced: session.dateGenerator(), winner: winner)
        }
    }
    
    private func produceAndRecordEvent(eventProducer: EventProducer) {
        do {
            if let measuringStarted = session.startingPoint {
                let event = eventProducer(measuringStarted)
                try session.recordEvent(event: event)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func debugPrint(_ error: Error) {
        if debug {
            print(error.localizedDescription)
        }
    }
    
}

struct MonitoringSettings: MonitoringData {
    var active: Bool
    var sendingIntervalMs: Int
    var maxSessionsForSending: Int
    var frequency: Int
}
