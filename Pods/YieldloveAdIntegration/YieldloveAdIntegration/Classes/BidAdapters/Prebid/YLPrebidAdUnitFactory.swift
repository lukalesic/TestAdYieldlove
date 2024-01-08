import PrebidMobile
import CoreGraphics

protocol PrebidAdUnit {
    func fetchDemand(adObject: AnyObject, completion: @escaping (PrebidMobile.ResultCode) -> Void)
    func addAdditionalSize(sizes: [CGSize])
    func setAppContent(_ appContentObject: PBMORTBAppContent)
}

protocol PrebidAdUnitFactory {
    var accountId: String? { get set }
    func setPrebidServerUrl() throws
    func makeBannerAdUnit(configId: String, size: CGSize, gamAdUnit: String, frameworks: [Signals.Api]?) -> PrebidAdUnit
    func makeInterstitialAdUnit(configId: String, gamAdUnit: String, frameworks: [Signals.Api]?) -> PrebidAdUnit
}

extension BannerAdUnit: PrebidAdUnit {
}

extension InterstitialAdUnit: PrebidAdUnit {
    func addAdditionalSize(sizes: [CGSize]) {
        // noop
    }
}

class YLPrebidAdUnitFactory: PrebidAdUnitFactory {
    
    private var _accountId: String?
    
    var accountId: String? {
        get { return _accountId }
        set {
            if let newAccountId = newValue {
                Prebid.shared.prebidServerAccountId = newAccountId
                _accountId = newAccountId
            }
        }
    }
    
    init() {
        Prebid.shared.timeoutMillis = PrebidConstants.prebidTimeoutMillis
        Prebid.shared.prebidServerHost = PrebidHost.Custom
    }
    
    func setPrebidServerUrl() throws {
        do {
            try Prebid.shared.setCustomPrebidServer(url: PrebidConstants.productionPrebidServerUrl)
        } catch {
            throw YLError.cantInitializePrebid
        }
    }
    
    func makeBannerAdUnit(configId: String, size: CGSize, gamAdUnit: String, frameworks: [Signals.Api]?) -> PrebidAdUnit {
        let adUnit = BannerAdUnit(configId: configId, size: size)
        let parameters = BannerParameters()
        parameters.api = frameworks
        adUnit.bannerParameters = parameters
        adUnit.pbAdSlot = gamAdUnit
        return adUnit
    }
    
    func makeInterstitialAdUnit(configId: String, gamAdUnit: String, frameworks: [Signals.Api]?) -> PrebidAdUnit {
        let adUnit = InterstitialAdUnit(configId: configId, minWidthPerc: 10, minHeightPerc: 10)
        let parameters = BannerParameters()
        parameters.api = frameworks
        adUnit.bannerParameters = parameters
        adUnit.pbAdSlot = gamAdUnit
        
        return adUnit
    }
}
