import Foundation
import GoogleMobileAds
import PrebidMobile
import PromiseKit
import YieldloveExternalConfiguration

class YLRefreshableBanner: YLBanner, RefreshTimerDelegate {
    
    var alreadyServedBannerView: YLBannerView?
    
    func refresh() {
        skipRecordingMonitoringEvents = true
        publisherDelegate?.bannerViewDidStartLoadingAd?()
        Promise.value(Void())
            .map(applyTargeting)
            .then(requestRefreshableAd)
            .catch(handleError)
    }
    
    override func callGam() throws -> Promise<YLBannerView> {
        let requestData = try getGamRequestData()
        if let servedView = alreadyServedBannerView {
            return refreshServedBanner(servedView: servedView, requestData: requestData)
        }
        return loadRefreshableBanner(requestData)
    }
    
    private func requestRefreshableAd() throws -> Promise<YLBannerView> {
        return try collectBids()
            .map(reportContextualTargeting)
            .then(callGam)
            .map(processBannerView)
    }

    private func loadRefreshableBanner(_ requestData: GamRequestData) -> Promise<YLBannerView> {
        return gamAdLoader.loadRefreshableBanner(gamRequestData: requestData, ylBanner: self)
            .map(keepReferenceToServedView)
    }
    
    private func refreshServedBanner(servedView: YLBannerView, requestData: GamRequestData) -> Promise<YLBannerView> {
        return gamAdLoader.refreshBanner(gamRequestData: requestData, ylBannerView: servedView)
    }
    
    private func keepReferenceToServedView(ylBannerView: YLBannerView) -> YLBannerView {
        alreadyServedBannerView = ylBannerView
        return ylBannerView
    }

}
