public protocol MonitoringData {
    var active: Bool { get }
    var sendingIntervalMs: Int { get }
    var maxSessionsForSending: Int { get }
    var frequency: Int { get }
}
