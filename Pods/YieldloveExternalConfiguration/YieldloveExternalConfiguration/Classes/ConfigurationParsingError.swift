enum ConfigurationParsingError: Error {
    case unableToParseDfpId
    case unableToParseConfigId
    case unableToParseAccountId
    case unableToParseCriteoPublisherAccountId
    case missingBannerSize
    case unableToParseConsentConfig
    case unableToParseJson
    case undefinedAppName
    case unableToParseAdSlotId
    case unableToParseZonesInAdSlotId
    case unableToParseAdUnitDataValues
    case unableToParseAdSlotData
    case unableToParseOverridePrivacyManagerId(_ key: String)
    case unableToParseOverrideProperties(_ key: String)
    case unableToParseOverrides
    case unableToFindCommonSection
    case unableToFindMonitoringSection
    case unableToFindAdSlotsSection
    case unableToFindModulesSection
    case unableToFindModule(_ moduleName: String)
    case unableToFindSlot(_ slotName: String)
    case dfpAppNetworkIsNotSet
    case malformedOpenRtbApiObject

    var errorDescription: String {
        switch self {
        case .unableToParseDfpId:
            return "Failed to parse DFP id."
        case .unableToParseConfigId:
            return "Failed to parse config id."
        case .unableToParseAccountId:
            return "Failed to parse account id."
        case .unableToParseCriteoPublisherAccountId:
            return "Failed to parse Criteo publisher account id."
        case .missingBannerSize:
            return "Failed to find banner sizes."
        case .unableToParseConsentConfig:
            return "Failed to parse iOS Consent settings."
        case .unableToParseAdSlotData:
            return "Failed to parse ad slot data."
        case .unableToParseOverridePrivacyManagerId(let key):
            return "CMP PrivacyManagerId is not defined for override \"\(key)\"."
        case .unableToParseOverrideProperties(let key):
            return "CMP Override key \"\(key)\" is not defined in config."
        case .unableToParseOverrides:
            return "CMP Overrides section is not defined config."
        case .unableToFindCommonSection:
            return "Common section is not defined config."
        case .unableToFindAdSlotsSection:
            return "AdSlots section is not defined config."
        case .unableToFindModulesSection:
            return "Modules section is not defined config."
        case .unableToFindModule(let moduleName):
            return "Unable to find \"\(moduleName)\" module."
        case .unableToFindSlot(let slotName):
            return "Unable to find slot \"\(slotName)\" definition."
        case .dfpAppNetworkIsNotSet:
            return "DfpAppNetwork is not defined config."
        case .malformedOpenRtbApiObject:
            return "Error parsing openRtbApi array."
        default:
            return ""
        }
    }
}
