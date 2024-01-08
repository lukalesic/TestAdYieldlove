import YieldloveExternalConfiguration

protocol RefreshTimerFactory {
    func makeTimer(autoRefreshTimeMs: Int, delegate: RefreshTimerDelegate, referenceHolder: YLReferenceHolder) -> RefreshTimer
}

class YLRefreshTimerFactory: RefreshTimerFactory {
    
    func makeTimer(autoRefreshTimeMs: Int, delegate: RefreshTimerDelegate, referenceHolder: YLReferenceHolder) -> RefreshTimer {
        let config = YLRefreshTimerConfig(refreshTimeMs: autoRefreshTimeMs, delegate: delegate, referenceHolder: referenceHolder)
        return YLRefreshTimer(config: config)
    }

}
