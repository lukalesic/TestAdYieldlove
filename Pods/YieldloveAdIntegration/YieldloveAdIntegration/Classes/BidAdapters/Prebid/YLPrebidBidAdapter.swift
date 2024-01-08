import PromiseKit
import PrebidMobile
import GoogleMobileAds

class YLPrebidBidAdapter: BidAdapter {

    var requestData: GAMRequest
    var publisherCustomTargeting: [String: String]?
    var prebidAdUnitFactory: PrebidAdUnitFactory
    var bannerAdUnitData: YLAdUnitData?

    init(requestData: GAMRequest, adUnitFactory: PrebidAdUnitFactory) {
        self.requestData = requestData
        self.publisherCustomTargeting = requestData.customTargeting // creates a copy
        self.prebidAdUnitFactory = adUnitFactory
        if Yieldlove.instance.debug == false {
            Prebid.shared.logLevel = LogLevel.severe
        }

        setPrebidCustomHeaders()
    }

    func getBannerBid(adUnitData: YLAdUnitData, timeEventRecorder: TimeEventRecorder?) -> Promise<BidTuple> {
        if adUnitData.skipPrebid {
            return Promise { seal in
                seal.fulfill((requestData, adUnitData))
            }
        }
        
        self.bannerAdUnitData = adUnitData
        let prebidAdUnit = getPrebidBannerAdUnit(adUnitData: adUnitData)
        return getBid(prebidAdUnit: prebidAdUnit, configId: adUnitData.configId, timeEventRecorder: timeEventRecorder)
                .map { (result: GAMRequest) -> BidTuple in
                    let adUnitDataWithCreativeSize = self.recordPrebidCreativeSize(gamRequest: result, adUnitData: adUnitData)
                    return (result, adUnitDataWithCreativeSize)
                }
    }

    func getInterstitialBid(bidData: InterstitialBidData, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest> {
        if bidData.prebidSkipped {
            return Promise { seal in
                seal.fulfill((requestData))
            }
        }
        let adUnit = getPrebidInterstitialAdUnit(bidData: bidData)
        return getBid(prebidAdUnit: adUnit, configId: bidData.configId, timeEventRecorder: timeEventRecorder)
    }

    private func setPrebidCustomHeaders() {
        Prebid.shared.addCustomHeader(name: "X-SDK-Version", value: YLConstants.version)
        if let bundleId = Bundle.main.bundleIdentifier {
            Prebid.shared.addCustomHeader(name: "X-Bundle", value: bundleId)
        }
    }

    private func getBid(prebidAdUnit: PrebidAdUnit, configId: String, timeEventRecorder: TimeEventRecorder?) -> Promise<GAMRequest> {
        return Promise { seal in
            setContentUrl(prebidAdUnit, self.requestData)
            timeEventRecorder?.recordRequestBids(bidAdapter: .Prebid)
            prebidAdUnit.fetchDemand(adObject: self.requestData) { (resultCode) in
                switch resultCode {
                case .prebidDemandFetchSuccess:
                    self.recordSuccessfulBidResponse(timeEventRecorder: timeEventRecorder, resultCode: resultCode)
                    self.resolveWhenFetchSuccess(configId: configId, dfpRequest: self.requestData, seal: seal)
                default:
                    self.recordSuccessfulBidResponse(timeEventRecorder: timeEventRecorder, resultCode: .prebidDemandFetchSuccess)
                    self.resolveDefaultFetch(configId: configId, pbsResultCode: resultCode, seal: seal)
                }
            }
        }
    }

    private func resolveWhenFetchSuccess(configId: String, dfpRequest: GAMRequest, seal: Resolver<GAMRequest>) {
        let keyValues = self.getBidSuccessfulKeyValues(configId: configId, dfpRequest: dfpRequest)
        self.requestData.customTargeting = keyValues
        seal.resolve(self.requestData, nil)
    }

    private func resolveDefaultFetch(configId: String, pbsResultCode: ResultCode, seal: Resolver<GAMRequest>) {
        let keyValues = self.getNoBidKeyValues(configId: configId, pbsResultCode: pbsResultCode)
        self.requestData.customTargeting = keyValues
        seal.resolve(self.requestData, nil)
    }

    private func getBidSuccessfulKeyValues(configId: String, dfpRequest: GAMRequest) -> [String: String] {
        let prebidTargeting = self.remapHBKeysToYLKeys(adRequest: dfpRequest)
        let metaTags = self.getBidSuccessfulMetaTags(configId: configId)
        let prebidAndMeta = self.combine(targ1: prebidTargeting, targ2: metaTags)
        return self.combine(targ1: prebidAndMeta, targ2: publisherCustomTargeting ?? [:])
    }

    private func getNoBidKeyValues(configId: String, pbsResultCode: ResultCode) -> [String: String] {
        let metaTags = self.getNoBidsMetaTags(configId: configId, pbsResultCode: pbsResultCode)
        return self.combine(targ1: metaTags, targ2: publisherCustomTargeting ?? [:])
    }

    private func getPrebidBannerAdUnit(adUnitData: YLAdUnitData) -> PrebidAdUnit {
        let size = adUnitData.bannerSizes[0].size
        let configId = adUnitData.configId
        let frameworks = adUnitData.frameworks
        let gamAdUnit = adUnitData.adUnit
        let prebidAdUnit = prebidAdUnitFactory.makeBannerAdUnit(configId: configId, size: size, gamAdUnit: gamAdUnit, frameworks: frameworks)
        var moreSizes: [CGSize] = []
        for adSize in adUnitData.bannerSizes {
            moreSizes.append(adSize.size)
        }
        prebidAdUnit.addAdditionalSize(sizes: moreSizes)
        return prebidAdUnit
    }

    private func remapHBKeysToYLKeys(adRequest: GAMRequest) -> [String: String] {
        var targetingDict = [String: String]()

        for keyValue in PrebidConstants.KeyValueTargeting.allCases {
            if let value = adRequest.customTargeting?[keyValue.rawValue] {
                if let ylKeyName = PrebidConstants.mappingDict[keyValue] {
                    targetingDict[ylKeyName] = value
                }
            }
        }
        return targetingDict
    }

    private func getPrebidInterstitialAdUnit(bidData: InterstitialBidData) -> PrebidAdUnit {
        return self.prebidAdUnitFactory.makeInterstitialAdUnit(configId: bidData.configId, gamAdUnit: bidData.gamAdUnit, frameworks: bidData.frameworks)
    }

    private func combine(targ1: [String: String], targ2: [String: String]) -> [String: String] {
        return targ1.merging(targ2, uniquingKeysWith: { (first, _) in first })
    }

    private func getBidSuccessfulMetaTags(configId: String) -> [String: String] {
        return [
            PrebidConstants.MetaTag.bidSuccess.rawValue: "true",
            PrebidConstants.MetaTag.meta.rawValue: "pid:\(configId).sb:t.pr:t"
        ]
    }

    private func getNoBidsMetaTags(configId: String, pbsResultCode: ResultCode) -> [String: String] {
        return [
            PrebidConstants.MetaTag.bidSuccess.rawValue: "false",
            PrebidConstants.MetaTag.meta.rawValue: "pid:\(configId).sb:f",
            PrebidConstants.MetaTag.resultCode.rawValue: "\(pbsResultCode.rawValue)"
        ]
    }

    private func setContentUrl(_ prebidAdUnit: PrebidAdUnit, _ dfpRequest: GAMRequest) {
        if let contentURL = dfpRequest.contentURL, !contentURL.isEmpty {
            let appContent = PBMORTBAppContent()
            appContent.url = contentURL
            prebidAdUnit.setAppContent(appContent)
        }
    }

    private func recordPrebidCreativeSize(gamRequest: GAMRequest, adUnitData: YLAdUnitData) -> YLAdUnitData {
        if let cacheIdKey = PrebidConstants.getTranslatedKey(key: .cache_id),
           let cacheId = gamRequest.customTargeting?[cacheIdKey] {
            adUnitData.prebidCacheId = cacheId
        }
        if let creativeSizeKey = PrebidConstants.getTranslatedKey(key: .size),
           let size = gamRequest.customTargeting?[creativeSizeKey] {
            adUnitData.prebidAdSize = YLCGSizeConverter.getCGSize(for: size)
        }
        return adUnitData
    }

    private func recordSuccessfulBidResponse(timeEventRecorder: TimeEventRecorder?, resultCode: ResultCode) {
        let code = BidAdapterResultCode.fromPrebidResultCode(code: resultCode)
        timeEventRecorder?.recordBidderRespondedSuccessfully(bidAdapter: .Prebid, resultCode: code)
    }

}
