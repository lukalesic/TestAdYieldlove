import GoogleMobileAds
import YieldloveExternalConfiguration
import PromiseKit

class YLRewardedAd: YLAd {
    
    private var completion: RewardedAdCompletion
    
    init(config: Config, completion: @escaping RewardedAdCompletion, request: GAMRequest, timeEventRecorder: TimeEventRecorder? = nil) {
        self.completion = completion
        super.init(config: config, adType: .rewarded, gamRequest: GAMRequest(), timeEventRecorder: timeEventRecorder)
    }
    
    func load(adSlotId: String) {
        self.getConfigurableAdUnitData(publisherAdSlot: adSlotId)
            .map(transformAdUnitData)
            .map(setAdUnitData)
            .map(recordAdUnitLoaded)
            .map(applyTargeting)
            .map(reportContextualTargeting)
            .then(callGam)
            .done(callSuccessCompletion)
            .catch(handleError)
            .finally(stopSession)
    }
    
    private func handleError(error: Error) {
        self.config.remoteReporter.report(err: error)
        self.completion(nil, error)
    }
        
    override func applyTargeting() throws {
        try applyAdManagerTargeting()
    }
    
    private func transformAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) -> YLAdUnitData {
        return YLAdUnitDataTransformer.transformRewardedAdUnitData(configurableAdUnitData: configurableAdUnitData)
    }
    
    private func recordAdUnitLoaded() {
        self.timeEventRecorder.recordAdUnitLoaded()
    }
    
    private func callGam() throws -> Promise<GADRewardedAd> {
        let adUnitData = try getAdUnitData()
        let requestData = (adUnitData, mergedGamRequest)
        return self.gamAdLoader.loadRewardedAd(gamRequestData: requestData, timeEventRecorder: timeEventRecorder)
    }
    
    private func callSuccessCompletion(rewardedAd: GADRewardedAd) {
        self.completion(rewardedAd, nil)
    }
    
}
