struct ExternalConfigConstants {
    static let defaultUpdateIntervalMs = 900000 // 15 minutes
    static let sdiInventoryStructure = "SDI"
    static let appNamePlaceholder = "#appName#"
    static let configJsonURL = "https://cdn.stroeerdigitalgroup.de/sdk/live/\(ExternalConfigConstants.appNamePlaceholder)/config.json"
}
