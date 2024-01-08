import Foundation

protocol RefreshTimerCollection {
    func setTimer(adUnit: String, _ timer: RefreshTimer)
    func removeTimer(_ timer: RefreshTimer)
}

class YLRefreshTimerCollection: RefreshTimerCollection {
    
    static let instance = YLRefreshTimerCollection()
    
    private var timers = [String: RefreshTimer]()
    
    func setTimer(adUnit: String, _ timer: RefreshTimer) {
        if let existing = timers[adUnit] {
            existing.stop()
        }
        timers[adUnit] = timer
    }
    
    func removeTimer(_ timer: RefreshTimer) {
        timers = timers.filter { _, value in
            return value !== timer
        }
    }
    
    func contains(_ timer: RefreshTimer) -> Bool {
        return timers.values.contains { $0 === timer }
    }
    
}
