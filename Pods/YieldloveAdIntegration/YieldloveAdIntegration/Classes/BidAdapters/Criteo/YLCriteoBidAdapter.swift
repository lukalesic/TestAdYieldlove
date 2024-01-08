import Foundation
import PromiseKit
import GoogleMobileAds
import CriteoPublisherSdk

class YLCriteoBidAdapter: BidAdapter {

    var criteoWrapper: CriteoWrapper
    var isPublisherIdSet: Bool = false

    init(criteo: CriteoWrapper = YLCriteoSdkWrapper(), publisherId: String?, verboseLogsEnabled: Bool = false) {
        self.criteoWrapper = criteo
        self.criteoWrapper.setVerboseLogsEnabled(verboseLogsEnabled: verboseLogsEnabled)
        self.setPublisherId(criteoPublisherId: publisherId)
    }

    func getBannerBid(adUnitData: YLAdUnitData, timeEventRecorder: TimeEventRecorder?) -> Promise<BidTuple> {
        if isPublisherIdSet {
            let biggestSize = self.giveTheBiggestSize(sizes: adUnitData.bannerSizes)
            let bannerAdUnit = CRBannerAdUnit.init(adUnitId: adUnitData.criteoAdUnitId, size: biggestSize)
            return self.criteoWrapper.loadBid(adUnit: bannerAdUnit, timeEventRecorder: timeEventRecorder).map { result in
                let adUnitDataWithCreativeSize = self.recordCreativeSize(gamRequest: result, adUnitData: adUnitData)
                return (result, adUnitDataWithCreativeSize)
            }
        }

        return resolveBannerEmptyRequest(adUnitData: adUnitData)
    }

    func getInterstitialBid(bidData: InterstitialBidData, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest> {
        if isPublisherIdSet {
            let interstitialAdUnit = CRInterstitialAdUnit.init(adUnitId: bidData.criteo.adUnitId)
            return self.criteoWrapper.loadBid(adUnit: interstitialAdUnit, timeEventRecorder: timeEventRecorder)
        }

        return resolveInterstitialEmptyRequest()
    }

    private func resolveBannerEmptyRequest(adUnitData: YLAdUnitData) -> Promise<BidTuple> {
        return Promise { seal in
            seal.resolve((GAMRequest(), adUnitData), nil)
        }
    }

    private func resolveInterstitialEmptyRequest() -> Promise<GAMRequest> {
        return Promise { seal in
            seal.resolve(GAMRequest(), nil)
        }
    }

    private func giveTheBiggestSize(sizes: [AdSize]) -> CGSize {
        var sizeCandidate: AdSize = GADAdSizeFromCGSize(CGSize(width: 0, height: 0))

        for sizeItem in sizes {
            let sizeItemArea = sizeItem.size.width * sizeItem.size.height
            let sizeCandidateArea = sizeCandidate.size.width * sizeCandidate.size.height

            if sizeItemArea > sizeCandidateArea {
                sizeCandidate = sizeItem
            }
        }

        return CGSize(width: sizeCandidate.size.width, height: sizeCandidate.size.height)
    }

    private func setPublisherId(criteoPublisherId: String?) {
        if let publisherId = criteoPublisherId {
            self.criteoWrapper.registerPublisherId(criteoPublisherId: publisherId)
            self.isPublisherIdSet = true
        } else {
            self.isPublisherIdSet = false
        }
    }

    private func recordCreativeSize(gamRequest: GAMRequest, adUnitData: YLAdUnitData) -> YLAdUnitData {
        let size = gamRequest.customTargeting?[CriteoConstants.size]
        adUnitData.criteoAdSize = YLCGSizeConverter.getCGSize(for: size)
        return adUnitData
    }
}
