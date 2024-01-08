struct YLRefreshTimerConfig {
    
    let refreshTimeMs: Int
    let delegate: RefreshTimerDelegate
    let referenceHolder: ReferenceHolder
    let timerProvider: Timer.Type
    let observableCenter: ObservableCenter
    let collection: RefreshTimerCollection
    
    init(refreshTimeMs: Int,
         delegate: RefreshTimerDelegate,
         referenceHolder: ReferenceHolder,
         timerProvider: Timer.Type = Timer.self,
         observableCenter: ObservableCenter = NotificationCenter.default,
         collection: RefreshTimerCollection = YLRefreshTimerCollection.instance
    ) {
        self.refreshTimeMs = refreshTimeMs
        self.delegate = delegate
        self.referenceHolder = referenceHolder
        self.timerProvider = timerProvider
        self.observableCenter = observableCenter
        self.collection = collection
    }
}
