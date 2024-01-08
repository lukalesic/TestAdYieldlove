import Foundation
import CriteoPublisherSdk
import PromiseKit
import GoogleMobileAds

protocol CriteoWrapper {
    func loadBid(adUnit: CRAdUnit, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest>
    func setVerboseLogsEnabled(verboseLogsEnabled: Bool)
    func registerPublisherId(criteoPublisherId: String)
    func enrichAdObject(originalRequest: GAMRequest, bid: CRBid)
}

class YLCriteoSdkWrapper: CriteoWrapper {

    func enrichAdObject(originalRequest: GAMRequest, bid: CRBid) {
        Criteo.shared().enrichAdObject(originalRequest, with: bid)
    }
    
    func registerPublisherId(criteoPublisherId: String) {
        Criteo.shared().registerPublisherId(criteoPublisherId, with: [])
    }
    
    func loadBid(adUnit: CRAdUnit, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest> {
        return Promise { seal in
            timeEventRecorder?.recordRequestBids(bidAdapter: .Criteo)
            Criteo.shared().loadBid(for: adUnit) { maybeBid in
                let request = GAMRequest()

                if let bid = maybeBid {
                    timeEventRecorder?.recordBidderRespondedSuccessfully(bidAdapter: .Criteo, resultCode: .SUCCESS)
                    self.enrichAdObject(originalRequest: request, bid: bid)
                    seal.resolve(request, nil)
                } else {
                    timeEventRecorder?.recordBidderRespondedSuccessfully(bidAdapter: .Criteo, resultCode: .NO_BIDS)
                    seal.resolve(GAMRequest(), nil)
                }
            }
        }
    }
    
    func setVerboseLogsEnabled(verboseLogsEnabled: Bool) {
        Criteo.setVerboseLogsEnabled(verboseLogsEnabled)
    }

}
