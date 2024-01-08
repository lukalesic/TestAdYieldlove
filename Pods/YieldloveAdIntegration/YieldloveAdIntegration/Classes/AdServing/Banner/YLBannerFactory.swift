import GoogleMobileAds

protocol BannerFactory {
    func make(ylAdUnitData: YLAdUnitData, bannerConfiguration: YLBannerConfiguration) -> LoadableBanner
}

class YLBannerFactory: BannerFactory {
    
    func make(ylAdUnitData: YLAdUnitData, bannerConfiguration: YLBannerConfiguration) -> LoadableBanner {
        if isRefreshingEnabled(ylAdUnitData: ylAdUnitData) {
            return YLRefreshableBanner(bannerConfiguration: bannerConfiguration)
        } else {
            return YLBanner(bannerConfiguration: bannerConfiguration)
        }
    }
    
    private func isRefreshingEnabled(ylAdUnitData: YLAdUnitData) -> Bool {
        return ylAdUnitData.autoRefreshTimeMs != nil
    }
    
}
