enum MonitoringError: Error {
    case multipleCallsToStartSession
    case multipleCallsToStopSession
    case sessionNotStarted
    case unknownEvent
    case invalidMonitoringUrl
    case addingEventToCompletedSessionNotAllowed
}
