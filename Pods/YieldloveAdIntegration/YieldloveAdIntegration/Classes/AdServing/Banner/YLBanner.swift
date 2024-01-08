import Foundation
import GoogleMobileAds
import PrebidMobile
import PromiseKit
import YieldloveExternalConfiguration

protocol LoadableBanner: AnyObject {
     func load(adSlotId: String, ylAdUnitData: YLAdUnitData)
 }

class YLBanner: YLAd, LoadableBanner {
    
    private(set) weak var publisherDelegate: YLBannerViewDelegate?
    let viewController: UIViewController
    
    init(bannerConfiguration: YLBannerConfiguration, timeEventRecorder: TimeEventRecorder? = nil) {
        let config = bannerConfiguration.config
        let publisherDelegate = bannerConfiguration.publisherDelegate
        let gamRequest = publisherDelegate.getGAMRequest?() ?? GAMRequest()
        self.publisherDelegate = publisherDelegate
        self.viewController = bannerConfiguration.viewController
        super.init(config: config, adType: .bannerAd, gamRequest: gamRequest, timeEventRecorder: timeEventRecorder)
        super.publisherCallString = bannerConfiguration.adSlotId
    }

    func load(adSlotId: String, ylAdUnitData: YLAdUnitData) {
        publisherDelegate?.bannerViewDidStartLoadingAd?()
        getConfigurableAdUnitData(publisherAdSlot: adSlotId)
            .map(processAdUnitData)
            .then(requestAd)
            .catch(handleError)
            .finally(stopSession)
    }
    
    func processAdUnitData(adUnitData: ConfigurableAdUnitData) throws {
        let ylAdUnitData = try transformAdUnitData(configurableAdUnitData: adUnitData)
        setAdUnitData(adUnitData: ylAdUnitData)
        recordAdUnitLoaded()
        try applyTargeting()
    }
    
    func processBannerView(ylBannerView: YLBannerView) throws -> YLBannerView {
        try passBannerToPublisher(ylBannerView: ylBannerView)
        deallocateAbandonedAds(ylBannerView: ylBannerView)
        return ylBannerView
    }
    
    func handleError(error: Error) {
        passBannerErrorToPublisher(bannerView: GADBannerView(), error: error)
        if !isErrorPartOfNormalGAMOperation(error) {
            config.remoteReporter.report(err: error)
        }
    }
    
    func getGamRequestData() throws -> GamRequestData {
        let ylAdUnitData = try getAdUnitData()
        return GamRequestData(adUnitData: ylAdUnitData,
                              gamRequest: mergedGamRequest,
                              publisherViewController: viewController,
                              publisherDelegate: publisherDelegate)
    }
    
    func analyzeAd(ylBannerView: YLBannerView) -> Promise<Void> {
        return AdWinnerAnalyzer.instance.getWinner(ylBannerView: ylBannerView)
            .done(recordAdAnalyzed)
    }
    
    func callGam() throws -> Promise<YLBannerView> {
        let requestData = try getGamRequestData()
        return gamAdLoader.loadBanner(gamRequestData: requestData, ylBanner: self)
    }
    
    private func requestAd() throws -> Promise<Void> {
        return try collectBids()
            .map(reportContextualTargeting)
            .then(callGam)
            .map(processBannerView)
            .then(analyzeAd)
    }
    
    private func transformAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) throws -> YLAdUnitData {
        return try YLAdUnitDataTransformer.transformBannerAdUnitData(configurableAdUnitData: configurableAdUnitData)
    }

    private func deallocateAbandonedAds(ylBannerView: YLBannerView) {
        config.referenceManager.deallocateAbandonedRefs()
    }
    
    private func passBannerToPublisher(ylBannerView: YLBannerView) throws {
        let ylAdUnitData = try getAdUnitData()
        ylBannerView.setPrebidCacheId(prebidCacheId: ylAdUnitData.prebidCacheId)
        ylBannerView.setAdSizesFrom(ylAdUnitData: ylAdUnitData)
        publisherDelegate?.bannerViewDidReceiveAd?(ylBannerView)
    }
    
    private func passBannerErrorToPublisher(bannerView: GADBannerView, error: Error) {
        let ylBannerView = YLBannerView(bannerView: bannerView)
        publisherDelegate?.bannerView?(ylBannerView, didFailToReceiveAdWithError: error)
    }
    
    private func isErrorPartOfNormalGAMOperation(_ error: Error) -> Bool {
        if case YLError.errorWasReportedByDelegate = error {
            return true
        }
        return false
    }
    
    private func recordAdUnitLoaded() {
        if !skipRecordingMonitoringEvents {
            timeEventRecorder.recordAdUnitLoaded()
        }
    }
    
    private func recordAdAnalyzed(winner: AdWinner) {
        if !skipRecordingMonitoringEvents {
            timeEventRecorder.recordAdAnalyzed(winner: winner.rawValue)
        }
    }

}
