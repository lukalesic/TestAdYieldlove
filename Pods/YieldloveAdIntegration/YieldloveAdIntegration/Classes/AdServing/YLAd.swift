import Foundation
import GoogleMobileAds
import PrebidMobile
import PromiseKit
import YieldloveExternalConfiguration

class YLAd {
    
    let config: Config
    let adType: AdType
    let timeEventRecorder: TimeEventRecorder
    let bidAdapterFactory: BidAdapterFactory
    let gamAdLoader: GamAdLoader
    var publisherCallString: String?
    
    private(set) var mergedGamRequest: GAMRequest
    private var ylAdUnitData: YLAdUnitData?
    var skipRecordingMonitoringEvents = false

    init(config: Config, adType: AdType, gamRequest: GAMRequest, timeEventRecorder: TimeEventRecorder?) {
        self.config = config
        self.adType = adType
        self.timeEventRecorder = timeEventRecorder ?? YLTimeEventRecorder(adType: adType, connection: .other)
        self.mergedGamRequest = YLGamRequestMerger.merge(gamRequest, Yieldlove.instance.adRequest)
        self.gamAdLoader = config.gamAdLoader
        self.bidAdapterFactory = YLBidAdapterFactory(prebidAdUnitFactory: config.prebidAdUnitFactory)
        self.timeEventRecorder.startSession()
    }

    func stopSession() {
        timeEventRecorder.stopSession()
        config.sessionsCollector.collect(session: timeEventRecorder.session)
    }

    func getConfigurableAdUnitData(publisherAdSlot: String) -> Promise<ConfigurableAdUnitData> {
        return config.configurationManager.getAdUnitData(publisherAdSlot: publisherAdSlot, adType: adType)
    }

    func reportContextualTargeting() {
        _ = config.contextualReporter.report(gamRequest: mergedGamRequest)
    }

    func getAdUnitData() throws -> YLAdUnitData {
        if let ylAdUnitData = self.ylAdUnitData {
            return ylAdUnitData
        } else {
            throw YLError.adUnitDataWasNotSet
        }
    }

    func setAdUnitData(adUnitData: YLAdUnitData) {
        self.ylAdUnitData = adUnitData
        self.ylAdUnitData?.publisherCallString = publisherCallString
    }

    func collectBids() throws -> Promise<Void> {
        let ylAdUnitData = try getAdUnitData()
        let bidsTuple = (mergedGamRequest, ylAdUnitData) as BidTuple
        let adapters = bidAdapterFactory.makeBidAdapters(bidTuple: bidsTuple)
        config.bidCollector.connectBidAdapters(adapters: adapters)
        return requestBids(bidsTuple: bidsTuple)
                .done { bidsResult in
                    self.ylAdUnitData = bidsResult.adUnitData
                    self.mergedGamRequest = bidsResult.request
                }
    }
    
    func applyTargeting() throws {
        try applyPrebidTargeting()
        try applyAdManagerTargeting()
    }
    
    private func requestBids(bidsTuple: BidTuple) -> Promise<BidTuple> {
        if skipRecordingMonitoringEvents {
            return config.bidCollector.collectBids(bidTuple: bidsTuple, adType: adType, timeEventRecorder: nil)
        }
        return config.bidCollector.collectBids(bidTuple: bidsTuple, adType: adType, timeEventRecorder: timeEventRecorder)
    }

    func applyAdManagerTargeting() throws {
        let ylAdUnitData = try getAdUnitData()
        let finalRequest = YLGamRequestMerger.mergeInto(request: mergedGamRequest, keyValues: ylAdUnitData.keyValueTargeting)
        finalRequest.customTargeting?[YLConstants.sdkVersionNumberKey] = YLConstants.version
        mergedGamRequest = finalRequest
    }
    
    private func applyPrebidTargeting() throws {
        let ylAdUnitData = try getAdUnitData()
        Targeting.shared.storeURL = ylAdUnitData.storeUrl
        Targeting.shared.itunesID = ylAdUnitData.itunesID
        Targeting.shared.addAppExtData(key: YLConstants.sdkVersionNumberKey, value: YLConstants.version)
        Targeting.shared.omidPartnerName = YLConstants.omidPartnerName
        Targeting.shared.omidPartnerVersion = YLConstants.omidPartnerVersion
    }
    
}
