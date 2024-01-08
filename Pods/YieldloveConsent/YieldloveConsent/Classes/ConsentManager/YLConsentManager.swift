import ConsentViewController

public protocol YLConsentManager {
    
    var messageLanguage: SPMessageLanguage { get set }
    
    func customConsentGDPR(vendors: [String], categories: [String], legIntCategories: [String], handler: @escaping (SPGDPRConsent) -> Void)
    
    func loadMessage(forAuthId authId: String?)
    
    func loadGDPRPrivacyManager(withId id: String, tab: SPPrivacyManagerTab)
    
    static func clearAllData()
}

extension SPConsentManager: YLConsentManager {
    
}
