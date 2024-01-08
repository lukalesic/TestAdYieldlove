import PromiseKit
import ConsentViewController
import YieldloveExternalConfiguration

@objc public class YLConsent: NSObject {
    
    @objc public static let instance = YLConsent()
    
    static var debug = false
    
    var consentMessage: YLConsentMessage?
    var privacyManager: YLPrivacyManager?
    var customConsent: YLCustomConsent?
    
    @objc public func setAppName(appName: String) {
        ExternalConfigurationManagerBuilder.instance.appName = appName
    }
    
    @objc public func enableDebug(isEnabled: Bool) {
        YLConsent.debug = isEnabled
        ExternalConfigurationManagerBuilder.instance.debug = isEnabled
    }
    
    @objc public func collect(viewController: UIViewController, delegate: ConsentDelegate, options: ConsentOptions? = ConsentOptions()) {
        consentMessage = YLConsentMessage(viewController: viewController, publisherDelegate: delegate)
        consentMessage?.show(options: options)
    }
    
    @objc public func showPrivacyManager(viewController: UIViewController,
                                         delegate: ConsentDelegate,
                                         options: ConsentOptions? = ConsentOptions()) {
        privacyManager = YLPrivacyManager(viewController: viewController, publisherDelegate: delegate)
        privacyManager?.show(options: options)
    }
    
    @objc public func customConsentTo(customConsentData: CustomConsentData,
                                      completionHandler: @escaping (SPGDPRConsent) -> Void,
                                      delegate: ConsentDelegate) {
        customConsent = YLCustomConsent(publisherDelegate: delegate)
        customConsent?.forward(consentData: customConsentData, completionHandler: completionHandler)
    }
    
    @objc public func clearConsentData(delegate: ConsentDelegate) {
        SPConsentManager.clearAllData()
    }

}
