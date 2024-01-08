import GoogleMobileAds
import PrebidMobile

typealias AdSize = GADAdSize

class YLAdUnitData: NSObject {
    
    var adUnit: String
    var configId: String
    var bannerSizes: [AdSize] = []
    var keyValueTargeting: [String: String] = [:]
    var prebidCacheId: String?
    var prebidAdSize: CGSize?
    var criteoAdSize: CGSize?
    var accountId: String?
    var adId: Int?
    var skipPrebid: Bool = false
    var criteoAdUnitId: String
    var criteoPublisherId: String?
    var frameworks: [Signals.Api]?
    var storeUrl: String?
    var itunesID: String?
    var autoRefreshTimeMs: Int?
    var publisherCallString: String?
    var responseIdentifier: String?
    
    init(adUnit: String, configId: String, criteoPublisherId: String?) {
        self.adUnit = adUnit
        self.criteoAdUnitId = adUnit
        self.criteoPublisherId = criteoPublisherId
        self.configId = configId
    }
    
    init(adUnit: String, configId: String, sizes: [AdSize], criteoPublisherId: String?) {
        self.adUnit = adUnit
        self.criteoAdUnitId = adUnit
        self.criteoPublisherId = criteoPublisherId
        self.configId = configId
        self.bannerSizes.append(contentsOf: sizes)
    }
    
    func setAdSizes(sizes: [AdSize]) {
        self.bannerSizes.append(contentsOf: sizes)
    }
    
    func setAdSizes(sizes: [NSValue]) {
        var adSizes = [AdSize]()
        for size in sizes {
            let adSize = GADAdSizeFromNSValue(size)
            adSizes.append(adSize)
        }
        
        self.setAdSizes(sizes: adSizes)
    }
    
    func addCustomTargeting(key: String, value: String) {
        self.keyValueTargeting[key] = value
    }
}
