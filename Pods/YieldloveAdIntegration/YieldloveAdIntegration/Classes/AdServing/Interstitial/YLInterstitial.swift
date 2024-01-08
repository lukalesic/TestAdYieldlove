import Foundation
import GoogleMobileAds
import PrebidMobile
import PromiseKit
import YieldloveExternalConfiguration

class YLInterstitial: YLAd {

    private var completion: InterstitialCompletion

    // swiftlint:disable line_length
    public init(config: Config, completion: @escaping InterstitialCompletion, request: GAMRequest, timeEventRecorder: TimeEventRecorder? = nil) {
        self.completion = completion
        super.init(config: config, adType: .interstitial, gamRequest: request, timeEventRecorder: timeEventRecorder)
    }
    // swiftlint:enable line_length
    
    public func load(adSlotId: String) {
        self.getConfigurableAdUnitData(publisherAdSlot: adSlotId)
                .map(transformAdUnitData)
                .map(setAdUnitData)
                .map(recordAdUnitLoaded)
                .map(applyTargeting)
                .then(collectBids)
                .map(reportContextualTargeting)
                .then(callGam)
                .done(callSuccessCompletion)
                .catch(handleError)
                .finally(stopSession)
    }

    private func callGam() throws -> Promise<GAMInterstitialAd> {
        let adUnitData = try getAdUnitData()
        let requestData = (adUnitData, mergedGamRequest)
        return self.gamAdLoader.loadInterstitial(gamRequestData: requestData, timeEventRecorder: timeEventRecorder)
    }

    private func transformAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) -> YLAdUnitData {
        return YLAdUnitDataTransformer.transformInterstitialAdUnitData(configurableAdUnitData: configurableAdUnitData)
    }
    
    private func callSuccessCompletion(gamInterstitial: GAMInterstitialAd) {
        self.completion(gamInterstitial, nil)
    }
    
    private func handleError(error: Error) {
        self.config.remoteReporter.report(err: error)
        self.completion(nil, error)
    }
    
    private func recordAdUnitLoaded() {
        self.timeEventRecorder.recordAdUnitLoaded()
    }
    
}
