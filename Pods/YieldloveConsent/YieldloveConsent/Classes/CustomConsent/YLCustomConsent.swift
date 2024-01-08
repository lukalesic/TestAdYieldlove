import PromiseKit
import ConsentViewController
import YieldloveExternalConfiguration

typealias CustomConsentCompletion = (SPGDPRConsent) -> Void

class YLCustomConsent {
    
    private let delegate: YLConsentDelegate
    private let consentManagerFactory: ConsentManagerFactory
    private let configurationManager: ConfigurationManager
    
    private var consentManager: YLConsentManager?
    
    init(publisherDelegate: ConsentDelegate, factory: ConsentManagerFactory = YLConsentManagerFactory()) {
        self.delegate = YLConsentDelegate(publisherDelegate: publisherDelegate)
        self.consentManagerFactory = factory
        self.configurationManager = ExternalConfigurationManagerBuilder.instance.externalConfigurationManager
    }
    
    func forward(consentData: CustomConsentData, completionHandler: @escaping CustomConsentCompletion) {
        makeConsentManager()
            .map(keepReferenceTo)
            .map { consentManager in
                self.submitCustomConsent(consentManager, consentData, completionHandler)
            }.catch(handleError)
    }
    
    private func makeConsentManager() -> Promise<YLConsentManager> {
        return consentManagerFactory.make(configurationManager: configurationManager,
                                          delegate: delegate,
                                          variant: nil)
    }
    
    private func keepReferenceTo(consentManager: YLConsentManager) -> YLConsentManager {
        self.consentManager = consentManager
        return consentManager
    }
    
    private func submitCustomConsent(_ consentManager: YLConsentManager,
                                     _ consentData: CustomConsentData,
                                     _ completionHandler: @escaping CustomConsentCompletion) {
        let handler = { (consent: SPGDPRConsent) in
            completionHandler(consent)
            YLConsent.instance.customConsent = nil
        }
        consentManager.customConsentGDPR(vendors: consentData.vendors,
                                         categories: consentData.categories,
                                         legIntCategories: consentData.legIntCategories,
                                         handler: handler)
    }
    
    private func handleError(error: Error) {
        if YLConsent.debug {
            print("Failed to submit custom consent to SourcePoint: " + error.localizedDescription)
        }
    }
    
}
