import GoogleMobileAds

@objc public class YLBannerView: NSObject {
    
    var bannerView: GADBannerView
    var prebidCacheId: String?
    var prebidAdSize: CGSize?
    var criteoAdSize: CGSize?
    var wasRefreshed: Bool
    
    @objc public init(bannerView: GADBannerView) {
        self.bannerView = bannerView
        self.wasRefreshed = false
    }
    
    @objc public func setPrebidCacheId(prebidCacheId: String?) {
        self.prebidCacheId = prebidCacheId
    }
    
    @objc public func getPrebidCacheId() -> String? {
        return prebidCacheId
    }
    
    @objc public func getPrebidAdSize() -> CGSize {
        return prebidAdSize ?? CGSize()
    }
        
    @objc public func setPrebidAdSize(prebidAdSize: CGSize) {
        self.prebidAdSize = prebidAdSize
    }
    
    @objc public func getCriteoAdSize() -> CGSize {
        return criteoAdSize ?? CGSize()
    }
        
    @objc public func setCriteoAdSize(criteoAdSize: CGSize) {
        self.criteoAdSize = criteoAdSize
    }
    
    @objc public func getBannerView() -> GADBannerView {
        return bannerView
    }
    
    @objc public func wasBannerRefreshed() -> Bool {
        return wasRefreshed
    }
    
    func setAdSizesFrom(ylAdUnitData: YLAdUnitData) {
        if let prebidAdSize = ylAdUnitData.prebidAdSize {
            setPrebidAdSize(prebidAdSize: prebidAdSize)
        }
        if let criteoAdSize = ylAdUnitData.criteoAdSize {
            setCriteoAdSize(criteoAdSize: criteoAdSize)
        }
    }
    
}
