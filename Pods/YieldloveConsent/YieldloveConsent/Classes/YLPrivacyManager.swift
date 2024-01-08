import PromiseKit
import ConsentViewController
import YieldloveExternalConfiguration

class YLPrivacyManager {
    
    private let delegate: YLConsentDelegate
    private let consentManagerFactory: ConsentManagerFactory
    private let configurationManager: ConfigurationManager
    
    private var consentManager: YLConsentManager?
    
    init(viewController: UIViewController, publisherDelegate: ConsentDelegate, factory: ConsentManagerFactory = YLConsentManagerFactory()) {
        self.delegate = YLConsentDelegate(publisherViewController: viewController, publisherDelegate: publisherDelegate)
        self.consentManagerFactory = factory
        self.configurationManager = ExternalConfigurationManagerBuilder.instance.externalConfigurationManager
    }
    
    func show(options: ConsentOptions?) {

        let setupConsentManager = setupConsentManager(options: options)
        let getConsentData = configurationManager.getConsentData(overrideProperties: options?.variant)
        
        when(fulfilled: setupConsentManager, getConsentData)
            .map { consentManager, consentData in
                consentManager.loadGDPRPrivacyManager(withId: consentData.privacyManagerId, tab: .Default)
            }.catch(handleError)
    }
    
    private func setupConsentManager(options: ConsentOptions?) -> Promise<YLConsentManager> {
        return makeConsentManager(variant: options?.variant)
            .map(keepReferenceTo)
            .map({self.setLanguage($0, options?.language)})
    }
    
    private func makeConsentManager(variant: String?) -> Promise<YLConsentManager> {
        return consentManagerFactory.make(configurationManager: configurationManager,
                                          delegate: delegate,
                                          variant: variant)
    }
    
    private func keepReferenceTo(consentManager: YLConsentManager) -> YLConsentManager {
        self.consentManager = consentManager
        return consentManager
    }
    
    private func setLanguage(_ consentManager: YLConsentManager, _ language: SPMessageLanguage?) -> YLConsentManager {
        var manager = consentManager
        if let lang = language {
            manager.messageLanguage = lang
        }
        return manager
    }
    
    private func handleError(error: Error) {
        if YLConsent.debug {
            switch error {
            case YLConsentManagerFactoryError.consentExternalConfigurationIsNotActive:
                print(self.makeErrorMessage(error))
            default:
                print("Could not show privacy manager: " + error.localizedDescription)
            }
        }
    }
    
    private func makeErrorMessage(_ error: Error) -> String {
        var msg = "Could not show privacy manager, because consent external configuration is not active: "
        msg += error.localizedDescription
        return msg
    }
    
}
