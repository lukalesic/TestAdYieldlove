protocol ConsentReader {
    
    func getVendorConsent() -> String?
    
    func getPurposeConsent() -> String?
    
    func getVendorLegitimateInterest() -> String?
    
    func getPurposeLegitimateInterest() -> String?
    
    func getPublisherRestrictionsFor(purposeId: Int) -> String?
    
    func getTCString() -> String?
    
}

class YLConsentReader: ConsentReader {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func getVendorConsent() -> String? {
        return userDefaults.object(forKey: ContextualTargetingConstants.iabVendorConsentsKey) as? String
    }
    
    func getPurposeConsent() -> String? {
        return userDefaults.object(forKey: ContextualTargetingConstants.iabPurposeConsentsKey) as? String
    }
    
    func getVendorLegitimateInterest() -> String? {
        return userDefaults.object(forKey: ContextualTargetingConstants.iabVendorLegitimateInterestKey) as? String
    }
    
    func getPurposeLegitimateInterest() -> String? {
        return userDefaults.object(forKey: ContextualTargetingConstants.iabPurposeLegitimateInterestKey) as? String
    }
    
    func getPublisherRestrictionsFor(purposeId: Int) -> String? {
        let pattern = ContextualTargetingConstants.iabPublisherRestrictionsKeyPattern
        let placeholder = ContextualTargetingConstants.iabPublisherRestrictionsPlaceholder
        let key = pattern.replacingOccurrences(of: placeholder, with: String(purposeId))
        return userDefaults.object(forKey: key) as? String
    }
    
    func getTCString() -> String? {
        return userDefaults.object(forKey: ContextualTargetingConstants.iabTCStringKey) as? String
    }

}
