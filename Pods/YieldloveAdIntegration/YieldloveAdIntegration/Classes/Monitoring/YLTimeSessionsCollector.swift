import Foundation
import PromiseKit
import YieldloveExternalConfiguration

typealias MonitoringDataGetter = () -> Promise<MonitoringData>

protocol SessionsCollector {
    func collect(session: TimeSession)
}

class YLTimeSessionsCollector: SessionsCollector {

    private(set) var sessions: [String] = []
    private(set) var lastReportDate: Date = Date()
    private let reporter: MonitoringReporter
    private let monitoringDataPromise: Promise<MonitoringData>
    private let consentEvaluator: MonitoringConsentEvaluator
    private let storage: TimeSessionsCollectorStorage
    
    // swiftlint:disable line_length
    public init(reporter: MonitoringReporter, consentEvaluator: MonitoringConsentEvaluator, monitoringDataGetter: MonitoringDataGetter, storage: TimeSessionsCollectorStorage = YLTimeSessionsCollectorStorage()) {
        self.reporter = reporter
        self.consentEvaluator = consentEvaluator
        self.monitoringDataPromise = monitoringDataGetter()
        self.storage = storage
        self.sessions = storage.popSessions()
        self.lastReportDate = storage.getLastReportDate()
    }
    // swiftlint:enable line_length
    
    deinit {
        storage.setSessions(sessions)
    }

    func collect(session: TimeSession) {
        _ = monitoringDataPromise.done { monitoringData in
            if monitoringData.active && self.consentEvaluator.canReportTimeSessions() {
                self.appendSession(session: session)
                if self.shouldReportThroughReporter(monitoringData) {
                    self.reportThroughReporter()
                }
            }
        }
    }

    private func appendSession(session: TimeSession) {
        let encoder = SessionEncoder()
        guard let eventAsJsonData = try? encoder.encode(session as? RelativeTimeSession) else {
            return
        }
        guard let asString = String(data: eventAsJsonData, encoding: .utf8) else {
            return
        }
        self.sessions.append(asString)
    }
    
    private func reportThroughReporter() {
        reporter.report(sessions: sessions)
        lastReportDate = Date()
        storage.clearSessions()
        storage.setLastReportDate(lastReportDate)
        sessions.removeAll()
    }
    
    private func isSendingIntervalExceeded(_ monitoringData: MonitoringData) -> Bool {
        let intervalInSecs = TimeInterval(monitoringData.sendingIntervalMs / 1000)
        return lastReportDate + intervalInSecs <= Date()
    }

    private func isSessionCountExceeded(_ monitoringData: MonitoringData) -> Bool {
        return sessions.count >= monitoringData.maxSessionsForSending
    }
    
    private func shouldReportThroughReporter(_ monitoringData: MonitoringData) -> Bool {
        return isSessionCountExceeded(monitoringData) || (isSendingIntervalExceeded(monitoringData) && !sessions.isEmpty)
    }

}
