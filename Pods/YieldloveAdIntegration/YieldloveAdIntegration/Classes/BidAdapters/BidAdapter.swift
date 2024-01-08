import PromiseKit
import GoogleMobileAds
import PrebidMobile

protocol BidAdapter {
    func getBannerBid(adUnitData: YLAdUnitData, timeEventRecorder: TimeEventRecorder?) -> Promise<BidTuple>
    func getInterstitialBid(bidData: InterstitialBidData, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest>
}

struct InterstitialBidData {
    var configId: String
    var gamAdUnit: String
    var prebidSkipped: Bool
    var criteo: CriteoBidData
    var frameworks: [Signals.Api]?
}

struct CriteoBidData {
    var adUnitId: String
}
