import Foundation

public protocol UserStorage {
    @discardableResult
    func synchronize() -> Bool
    func set(_ value: Any?, forKey: String)
    func double(forKey: String) -> Double
    func array(forKey: String) -> [Any]?
    func removeObject(forKey: String)
}

extension UserDefaults: UserStorage {
}

protocol TimeSessionsCollectorStorage {
    func setSessions(_ sessions: [String])
    func popSessions() -> [String]
    func clearSessions()
    func setLastReportDate(_ date: Date)
    func getLastReportDate() -> Date
}

class YLTimeSessionsCollectorStorage: TimeSessionsCollectorStorage {
    
    static let sessionsUserStorageKey = "monitoring-sessions"
    static let lastReportDateUserStorageKey = "monitoring-reporter-called"
    
    private let userStorage: UserStorage
    
    init(userStorage: UserStorage = UserDefaults.standard) {
        self.userStorage = userStorage
    }
    
    func setSessions(_ sessions: [String]) {
        userStorage.set(sessions, forKey: Self.sessionsUserStorageKey)
    }
    
    func popSessions() -> [String] {
        let stored = userStorage.array(forKey: Self.sessionsUserStorageKey)
        clearSessions()
        return (stored as? [String]) ?? []
    }
    
    func clearSessions() {
        userStorage.removeObject(forKey: Self.sessionsUserStorageKey)
        userStorage.synchronize()
    }
    
    func setLastReportDate(_ date: Date) {
        userStorage.set(date.timeIntervalSince1970, forKey: Self.lastReportDateUserStorageKey)
    }
    
    func getLastReportDate() -> Date {
        let timeSince = userStorage.double(forKey: Self.lastReportDateUserStorageKey)
        return Date(timeIntervalSince1970: timeSince)
    }
    
}
