public enum AdType {
    case bannerAd
    case interstitial
    case rewarded
    
    public var isBannerAd: Bool {
        return self == .bannerAd
    }
}
