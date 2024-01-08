import PromiseKit
import GoogleMobileAds
import Foundation
import YieldloveExternalConfiguration

typealias BidTuple = (request: GAMRequest, adUnitData: YLAdUnitData)

protocol BidsCollector {
    func connectBidAdapters(adapters: [BidAdapter])
    func collectBids(bidTuple: BidTuple, adType: AdType, timeEventRecorder: TimeEventRecorder?) -> Promise<BidTuple>
}

class YLBidsCollector: BidsCollector {
    
    private var adapters: [BidAdapter] = []
    
    func connectBidAdapters(adapters: [BidAdapter]) {
        self.adapters = adapters
    }
    
    func collectBids(bidTuple: BidTuple, adType: AdType, timeEventRecorder: TimeEventRecorder?) -> Promise<BidTuple> {
        let (originalRequest, adUnitData) = bidTuple
        if adType.isBannerAd {
            return collectBannerBids(request: originalRequest, adUnitData: adUnitData, eventRecorder: timeEventRecorder)
        }
        return collectInterstitialBids(request: originalRequest, adUnitData: adUnitData, timeEventRecorder: timeEventRecorder)
    }
    
    private func collectBannerBids(request: GAMRequest, adUnitData: YLAdUnitData, eventRecorder: TimeEventRecorder?) -> Promise<BidTuple> {
        var gamRequest: GAMRequest = request
        let bidTuples: [Promise<BidTuple>] = self.askForBannerBids(adUnitData: adUnitData, timeEventRecorder: eventRecorder)
        
        return firstly {
            when(fulfilled: bidTuples)
        }
        .then {(bidResults: [BidTuple]) -> Promise<BidTuple> in
            bidResults.forEach {bidResult in
                gamRequest = self.enrichGAMRequest(gamRequest: gamRequest, bidRequest: bidResult.0)
            }
            return Promise { seal in
                seal.fulfill((gamRequest, adUnitData))
            }
        }
    }
    
    private func collectInterstitialBids(request: GAMRequest, adUnitData: YLAdUnitData, timeEventRecorder: TimeEventRecorder?)
            -> Promise<BidTuple> {
        var gamRequest: GAMRequest = request
        let bidData = self.prepareInterstitialBidData(adUnitData: adUnitData)
        
        let bidRequests: [Promise<GAMRequest>] = self.askForInterstitialBids(bidData: bidData, timeEventRecorder: timeEventRecorder)
        
        return firstly {
            when(fulfilled: bidRequests)
        }
        .then {(bidResults: [GAMRequest]) -> Promise<BidTuple> in
            bidResults.forEach {bidResult in
                gamRequest = self.enrichGAMRequest(gamRequest: gamRequest, bidRequest: bidResult)
            }
            return Promise { seal in
                seal.fulfill((gamRequest, adUnitData))
            }
        }
    }
    
    private func askForBannerBids(adUnitData: YLAdUnitData, timeEventRecorder: TimeEventRecorder?) -> [Promise<BidTuple>] {
        return self.adapters.map { adapter in
            return adapter.getBannerBid(adUnitData: adUnitData, timeEventRecorder: timeEventRecorder)
        }
    }
    
    private func prepareInterstitialBidData(adUnitData: YLAdUnitData) -> InterstitialBidData {
        let criteoData = CriteoBidData(adUnitId: adUnitData.criteoAdUnitId)
        return InterstitialBidData(
            configId: adUnitData.configId,
            gamAdUnit: adUnitData.adUnit,
            prebidSkipped: adUnitData.skipPrebid,
            criteo: criteoData,
            frameworks: adUnitData.frameworks
        )
    }
    
    private func enrichGAMRequest(gamRequest: GAMRequest, bidRequest: GAMRequest) -> GAMRequest {
        return YLGamRequestMerger.merge(gamRequest, bidRequest)
    }
    
    private func askForInterstitialBids(bidData: InterstitialBidData, timeEventRecorder: TimeEventRecorder?) -> [Promise<GAMRequest>] {
        return self.adapters.map { adapter in
            return adapter.getInterstitialBid(bidData: bidData, timeEventRecorder: timeEventRecorder)
        }
    }
}
