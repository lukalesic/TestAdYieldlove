import AdSupport
import GoogleMobileAds
import PromiseKit
import YieldloveExternalConfiguration

protocol ContextualTargetingReporter {
    func report(gamRequest: GAMRequest) -> Promise<Void>
}

class YLContextualTargetingDataReporter: ContextualTargetingReporter {
    
    private let idfaManager: ASIdentifierManager
    private let adexConsentEvaluator: AdexConsentEvaluator
    private let adexApiCaller: AdexApiCaller

    init(
        idfaManager: ASIdentifierManager = ASIdentifierManager.shared(),
        consentEvaluator: AdexConsentEvaluator = TheAdexConsentEvaluator(),
        theAdexApiCaller: AdexApiCaller = TheAdexApiCaller()
    ) {
        self.idfaManager = idfaManager
        self.adexConsentEvaluator = consentEvaluator
        self.adexApiCaller = theAdexApiCaller
    }
    
    @discardableResult
    func report(gamRequest: GAMRequest) -> Promise<Void> {
        if let idfa = getIdentifierForAdvertising(),
           let contentURL = gamRequest.contentURL,
           !contentURL.isEmpty,
           hasConsent() {
                let contextualTargetingData = YLContextualTargetingData(idfa: idfa, contentURL: contentURL)
                return self.adexApiCaller.submit(data: contextualTargetingData)
        }
        return Promise { seal in
            seal.reject(ContextualTargetingError.conditionsForReportingToTheAdexNotMet)
        }
    }
    
    private func hasConsent() -> Bool {
        return adexConsentEvaluator.canReportToTheAdex()
    }
    
    private func getIdentifierForAdvertising() -> String? {
        let idfa = self.idfaManager.advertisingIdentifier.uuidString
        if idfa != ContextualTargetingConstants.idfaInvalidString {
            return idfa
        }
        return nil
    }
    
}
