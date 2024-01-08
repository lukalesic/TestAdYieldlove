import PromiseKit

struct ExternalConfigAdUnitData: ConfigurableAdUnitData {
    var adUnit: String
    var configId: String
    var sizes: BannerSizes?
    var keyValueTargeting: [String: String] = [:]
    var accountId: String?
    var skipPrebid: Bool = false
    var criteoPublisherId: String?
    var storeUrl: String?
    var itunesID: String?
    var openRtbApi: [Int]?
    var autoRefreshTimeMs: Int?
}

struct ExternalConfigConsentData: ConfigurableConsentData {
    var accountId: String
    var isActive: Bool
    var propertyId: Int
    var propertyName: String
    var privacyManagerId: String
}

struct ExternalConfigMonitoringData: MonitoringData {
    var active: Bool
    var sendingIntervalMs: Int
    var maxSessionsForSending: Int
    var frequency: Int
}

protocol ConfigurationParser {
    
    func parseAdUnit(adSlotName: String, configJSON: String, adType: AdType) throws -> ConfigurableAdUnitData
    
    func getSyncInterval(configJSON: String) throws -> Int
    
    func getConsentData(configJSON: String, overrideProperties: String?) throws -> ConfigurableConsentData
    
    func getMonitoringData(configJSON: String) throws -> MonitoringData
}

class ExternalConfigurationParser: ConfigurationParser {
    
    static let defaultFrequency = 1
    static let defaultSendingIntervalInMs = 24 * 60 * 60 * 1000  // 24 hours
    static let defaultMaxSessionsForSending = 1000

    func parseAdUnit(adSlotName: String, configJSON: String, adType: AdType) throws -> ConfigurableAdUnitData {
        do {
            let config = try getConfig(configJSON: configJSON)
            let inventoryStructure = try getAdSlotType(config: config)
            let adSlotDescriptor = AdSlotDescriptor(
                    adSlotId: adSlotName,
                    adType: adType,
                    adSlotType: inventoryStructure
            )
            let adSlotData = try AdSlotDataParser.getAdSlotData(adSlotDescriptor: adSlotDescriptor)
            return try ExternalConfigurationParser.parseConfiguration(config: config, adSlotData: adSlotData)
        } catch {
            ExternalConfigurationParser.printErrorDescriptionInDebugMode(error: error, adSlotId: adSlotName)
            throw error
        }
    }

    private func getConfig(configJSON: String) throws -> [String: Any] {
        guard
                let data = configJSON.data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                else {
            throw ConfigurationParsingError.unableToParseJson
        }

        return json
    }

    func getSyncInterval(configJSON: String) throws -> Int {
        do {
            let config = try getConfig(configJSON: configJSON)
            return try ExternalConfigurationParser.getUpdateInterval(config)
        } catch {
            ExternalConfigurationParser.printErrorDescriptionInDebugMode(error: error)
            throw error
        }
    }

    func getConsentData(configJSON: String, overrideProperties: String?) throws -> ConfigurableConsentData {
        do {
            let config = try getConfig(configJSON: configJSON)
            return try ExternalConfigurationParser.getConsentDataFromConfig(config, overrideProperties)
        } catch {
            ExternalConfigurationParser.printErrorDescriptionInDebugMode(error: error)
            throw error
        }
    }
    
    func getMonitoringData(configJSON: String) throws -> MonitoringData {
        do {
            let config = try getConfig(configJSON: configJSON)
            return try ExternalConfigurationParser.getMonitoringDataFromConfig(config)
        } catch {
            ExternalConfigurationParser.printErrorDescriptionInDebugMode(error: error)
            throw error
        }
    }

    func getAdSlotType(config: [String: Any]) throws -> AdSlotType {
        return try ExternalConfigurationParser.getInventoryStructure(config) == AdSlotType.flexible.rawValue ? .flexible : .sdi
    }

    static func parseConfiguration(config: [String: Any], adSlotData: AdSlotData) throws -> ConfigurableAdUnitData {
        var data = ExternalConfigAdUnitData(
                adUnit: try getFullDfpId(config, adSlotData),
                configId: try getConfigId(config, adSlotData),
                sizes: try AdSizesParser.getSizes(config, adSlotData),
                accountId: try getPrebidAccountId(config: config),
                skipPrebid: try !isPrebidAllowed(config, adSlotData),
                criteoPublisherId: try? getCriteoPublisherId(config: config),
                storeUrl: try getStoreUrl(config: config),
                itunesID: try getItunesID(config: config),
                openRtbApi: try? getOpenRtbApi(config: config),
                autoRefreshTimeMs: getAutoRefreshTimeMs(config, adSlotData)
        )

        let requestKeyValues = KeyValuesParser.getKeyValues(config, adSlotData)
        for (key, value) in requestKeyValues {
            data.keyValueTargeting[key] = value
        }

        return data
    }
    
    static func getMonitoringDataFromConfig(_ config: [String: Any]) throws -> MonitoringData {
        guard let section = config["monitoring"] as? [String: Any] else {
            throw ConfigurationParsingError.unableToFindMonitoringSection
        }
        guard let active = section["active"] as? Bool else {
            throw ConfigurationParsingError.unableToParseConsentConfig
        }
        
        return try parseAdditionalMonitoringData(active: active, section: section)
    }
    
    private static func parseAdditionalMonitoringData(active: Bool, section: [String: Any]) throws -> MonitoringData {
        let sendingIntervalMs = section["sendingIntervalMs"] as? Int ?? defaultSendingIntervalInMs
        let maxSessionsForSending = section["maxSessionsForSending"] as? Int ?? defaultMaxSessionsForSending
        let frequency = section["frequency"] as? Int ?? defaultFrequency
        
        return ExternalConfigMonitoringData(
            active: active,
            sendingIntervalMs: sendingIntervalMs,
            maxSessionsForSending: maxSessionsForSending,
            frequency: frequency)
    }

    private static func printErrorDescriptionInDebugMode(error: Error, adSlotId: String = "") {
        if ExternalConfigurationManagerBuilder.instance.debug {
            let prefix = "Failed to parse external configuration. Due to:"
            if let configParserError = error as? ConfigurationParsingError {
                print("\(prefix) \(configParserError.errorDescription) For slot: \(adSlotId)")
            } else {
                print("\(prefix) unknown cause")
            }
        }
    }
    
    private static func getOpenRtbApi(config: [String: Any]) throws -> [Int]? {
        if let openRtb = config["openRtb"] as? [String: Any] {
            if let apis = openRtb["apis"] as? [[String: Any]] {
                var apiFrameworks: [Int] = []
                for item in apis {
                    guard let framework = item["framework"] as? Int else {
                        throw ConfigurationParsingError.malformedOpenRtbApiObject
                    }
                    apiFrameworks.append(framework)
                }
                return apiFrameworks.isEmpty ? nil : apiFrameworks
            }
        }
        return nil
    }
    
    private static func getAutoRefreshTimeMs(_ config: [String: Any], _ adSlotData: AdSlotData) -> Int? {
        let adSlot = try? getAdSlot(config, adSlotData)
        return adSlot?["autoRefreshTimeMs"] as? Int
    }

    private static func getAlternativeAppName(_ config: [String: Any], _ adSlotData: AdSlotData) -> String? {
        let adSlot = try? getAdSlot(config, adSlotData)
        return adSlot?["dfpiOSAppName"] as? String
    }

    private static func getAdSlot(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> [String: Any] {
        let adSlots = try getAdSlots(config)
        guard let adSlotName = getAdSlotBasedOnType(adSlotData: adSlotData) else {
            throw ConfigurationParsingError.unableToParseAdSlotData
        }
        guard let adSlot = adSlots[adSlotName] as? [String: Any] else {
            throw ConfigurationParsingError.unableToFindSlot(adSlotName)
        }
        return adSlot
    }

    private static func getAdSlots(_ config: [String: Any]) throws -> [String: Any] {
        guard let adSlots = config["adSlots"] as? [String: Any] else {
            throw ConfigurationParsingError.unableToFindAdSlotsSection
        }
        return adSlots
    }

    private static func getFullDfpId(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> String {
        let adSlotPrefix = try getAdSlotPrefix(config, adSlotData)
        return "/\(adSlotPrefix)/\(stripQueryString(adSlotData.adSlotId))"
    }

    private static func getAdSlotPrefix(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> String {
        let dfpAccountId = try getDfpAccountId(config)
        if let appName = try getAppName(config, adSlotData), !appName.isEmpty, adSlotData.adSlotType == AdSlotType.sdi {
            return "\(dfpAccountId)/\(appName)"
        } else {
            return "\(dfpAccountId)"
        }
    }

    private static func getAppName(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> String? {
        let common = try getCommon(config)
        var appName = common["dfpiOSAppName"] as? String

        if let alternativeAppName = getAlternativeAppName(config, adSlotData) {
            appName = alternativeAppName
        }

        return appName
    }

    private static func getDfpAccountId(_ config: [String: Any]) throws -> String {
        let common = try getCommon(config)
        guard let dfpAccountId = common["dfpAppNetwork"] as? String, !dfpAccountId.isEmpty else {
            throw ConfigurationParsingError.dfpAppNetworkIsNotSet
        }
        return dfpAccountId
    }

    private static func getConfigId(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> String {
        guard let adSlot = try? getAdSlot(config, adSlotData),
              let configId = adSlot["iOSPrebidConfigId"] as? String, !configId.isEmpty else {
            throw ConfigurationParsingError.unableToParseConfigId
        }
        return configId
    }

    private static func stripQueryString(_ publisherAdSlot: String) -> String {
        var input = publisherAdSlot
        let index = input.firstIndex(of: "?") ?? input.endIndex
        let range = index..<input.endIndex
        input.removeSubrange(range)
        return input
    }

    private static func getModules(_ config: [String: Any]) throws -> [[String: Any]] {
        guard let modulesArray = config["modules"] as? [[String: Any]] else {
            throw ConfigurationParsingError.unableToFindModulesSection
        }
        return modulesArray
    }

    private static func getModule(_ config: [String: Any], _ moduleName: String) throws -> [String: Any] {
        let modules = try getModules(config)
        guard let module = modules.first(where: { $0.keys.contains(moduleName) }),
              let moduleData = module[moduleName] as? [String: Any] else {
            throw ConfigurationParsingError.unableToFindModule(moduleName)
        }
        return moduleData
    }

    static func getPrebidAccountId(config: [String: Any]) throws -> String? {
        let prebid = try getModule(config, "PREBID")
        guard let accountId = prebid["yieldloveAccountId"] as? String, !accountId.isEmpty else {
            throw ConfigurationParsingError.unableToParseAccountId
        }
        return accountId
    }
    
    static func getCriteoPublisherId(config: [String: Any]) throws -> String? {
        let criteo = try getModule(config, "CRITEO")
        guard let accountId = criteo["accountId"] as? String, !accountId.isEmpty else {
            throw ConfigurationParsingError.unableToParseCriteoPublisherAccountId
        }
        return accountId
    }

    static func getConsentDataFromConfig(_ config: [String: Any], _ overrideProperties: String? = nil) throws -> ConfigurableConsentData {
        let sp = try getModule(config, "iOSSOURCEPOINT")
        var consentData = try getConsentDataFromModule(sp: sp)
        if let overrides = overrideProperties {
            consentData = try overrideConsentData(sp: sp, consentData: consentData, overrideProperties: overrides)
        }
        return consentData
    }

    static func getInventoryStructure(_ config: [String: Any]) throws -> String? {
        let common = try getCommon(config)
        if let inventoryStructure = common["inventoryStructure"] as? String {
            return inventoryStructure
        } else {
            return ExternalConfigConstants.sdiInventoryStructure
        }
    }

    private static func getCommon(_ config: [String: Any]) throws -> [String: Any] {
        guard let common = config["common"] as? [String: Any] else {
            throw ConfigurationParsingError.unableToFindCommonSection
        }
        return common
    }

    static func getUpdateInterval(_ config: [String: Any]) throws -> Int {
        let common = try getCommon(config)
        guard let updateIntervalMs = common["updateIntervalMs"] as? Int else {
            return ExternalConfigConstants.defaultUpdateIntervalMs
        }
        return updateIntervalMs

    }

    static func isPrebidAllowed(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> Bool {
        guard let adSlot = try? getAdSlot(config, adSlotData) else {
            throw ConfigurationParsingError.unableToParseAdSlotData
        }
        return adSlot["rtaAuction"] as? Bool ?? false
    }

    static func getAdSlotBasedOnType(adSlotData: AdSlotData) -> String? {
        if adSlotData.adSlotType == AdSlotType.sdi {
            return adSlotData.adSlot
        } else {
            return adSlotData.adSlotId
        }
    }

    private static func getConsentDataFromModule(sp: [String: Any]) throws -> ExternalConfigConsentData {
        guard let accountId = sp["sourcepointAccountId"] as? String,
              let isActive = sp["active"] as? Bool,
              let propertyString = sp["propertyId"] as? String,
              let propertyId = Int(propertyString),
              let propertyName = sp["propertyName"] as? String,
              let privacyManagerId = sp["privacyManagerId"] as? String else {
            throw ConfigurationParsingError.unableToParseConsentConfig
        }
        return ExternalConfigConsentData(
                accountId: accountId,
                isActive: isActive,
                propertyId: propertyId,
                propertyName: propertyName,
                privacyManagerId: privacyManagerId)
    }

    private static func overrideConsentData(sp: [String: Any], consentData: ExternalConfigConsentData, overrideProperties: String) throws -> ExternalConfigConsentData {
        var externalConfigConsentData = consentData
        let overridesSp = try getOverride(sourcepointConfig: sp, overrideProperties: overrideProperties)
        if let overriddenPrivacyManagerId = overridesSp["privacyManagerId"] as? String {
            externalConfigConsentData.privacyManagerId = overriddenPrivacyManagerId
        }
        if let overriddenPropertyName = overridesSp["propertyName"] as? String {
            externalConfigConsentData.propertyName = overriddenPropertyName
        }
        if let overriddenPropertyId = overridesSp["propertyId"] as? String {
            if let overriddenPropertyIdAsInt = Int(overriddenPropertyId) {
                externalConfigConsentData.propertyId = overriddenPropertyIdAsInt
            }
        }
        return externalConfigConsentData
    }

    private static func getOverride(sourcepointConfig: [String: Any], overrideProperties: String) throws -> [String: Any] {
        let overrides = try getOverrides(sourcepointConfig)
        guard let overridesSp = overrides[overrideProperties] as? [String: Any] else {
            throw ConfigurationParsingError.unableToParseOverrideProperties(overrideProperties)
        }
        return overridesSp
    }

    private static func getOverrides(_ sourcepointConfig: [String: Any]) throws -> [String: Any] {
        guard let overrides = sourcepointConfig["overrides"] as? [String: Any] else {
            throw ConfigurationParsingError.unableToParseOverrides
        }
        return overrides
    }

    private static func getStoreUrl(config: [String: Any]) throws -> String? {
        let common = try getCommon(config)
        return common["iOSStoreUrl"] as? String
    }

    private static func getItunesID(config: [String: Any]) throws -> String? {
        let common = try getCommon(config)
        return common["iOSITunesId"] as? String
    }

}
