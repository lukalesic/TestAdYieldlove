class YLTimeSessionCalculator {
    static func getServedInTime(session: TimeSession) -> TimeInterval {
        if let responseEvent = session.getEvent(eventType: "GamRespondedSuccessfully") {
            let eventTime = responseEvent.timeSinceMeasuringStarted
            return TimeInterval(eventTime) / 1000
        }
        return 0
    }
}
