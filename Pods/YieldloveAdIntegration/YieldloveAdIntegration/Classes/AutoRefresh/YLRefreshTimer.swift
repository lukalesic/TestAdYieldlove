import UIKit
import YieldloveExternalConfiguration

protocol RefreshTimerDelegate: AnyObject {
    func refresh()
}

protocol RefreshTimer: AnyObject {
    func start()
    func stop()
}

protocol ObservableCenter {
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?)
}

extension NotificationCenter: ObservableCenter {
}

class YLRefreshTimer: NSObject, RefreshTimer {

    private static let msInSecond = 1000
    private static let tolerance = 1.0 // timer tolerance saves resources
    
    private let delegate: RefreshTimerDelegate
    private let refreshInSeconds: Double
    private let timerProvider: Timer.Type
    private let observableCenter: ObservableCenter
    private let collection: RefreshTimerCollection
    
    private var state: RefreshTimerState = .initialized
    private weak var referenceHolder: ReferenceHolder?

    init(config: YLRefreshTimerConfig) {
        self.refreshInSeconds = Double(config.refreshTimeMs / Self.msInSecond)
        self.delegate = config.delegate
        self.referenceHolder = config.referenceHolder
        self.timerProvider = config.timerProvider
        self.observableCenter = config.observableCenter
        self.collection = config.collection
        super.init()
        listenToAppNotifications()
    }
    
    func start() {
        if state.isStartable {
            state = .running
            let timer = timerProvider.scheduledTimer(withTimeInterval: refreshInSeconds, repeats: true) { [weak self] timer in
                if let refreshTimer = self {
                    refreshTimer.fireTimer(timer)
                }
            }
            timer.tolerance = Self.tolerance
        }
    }
    
    func stop() {
        if state.isStoppable {
            state = .stopped
        }
    }
    
    @objc func fireTimer(_ timer: Timer) {
        switch state {
        case .initialized:
            return
        case .running:
            refresh(timer)
        case .paused:
            timer.invalidate()
        case .stopped:
            destroy(timer)
        }
    }
    
    private func pause() {
        state = .paused
    }
    
    private func refresh(_ timer: Timer) {
        if let referenceHolder = self.referenceHolder, referenceHolder.areReferencedObjectsStillInMemory {
            delegate.refresh()
        } else {
            destroy(timer)
        }
    }
    
    private func listenToAppNotifications() {
        observableCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        observableCenter.addObserver(self,
                                       selector: #selector(appMovedToForeground),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
    }
    
    private func destroy(_ timer: Timer) {
        timer.invalidate()
        collection.removeTimer(self)
    }
    
    @objc private func appMovedToBackground() {
        pause()
    }
    
    @objc private func appMovedToForeground() {
        start()
    }
    
}
