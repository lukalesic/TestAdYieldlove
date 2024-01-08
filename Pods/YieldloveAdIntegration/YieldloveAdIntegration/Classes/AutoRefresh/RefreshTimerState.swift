enum RefreshTimerState {
    case initialized
    case running
    case paused
    case stopped
    
    var isStartable: Bool {
        return self == .initialized || self == .paused
    }
    
    var isPausable: Bool {
        return self == .running
    }
    
    var isStoppable: Bool {
        return self == .initialized || self == .paused || self == .running
    }
    
}
