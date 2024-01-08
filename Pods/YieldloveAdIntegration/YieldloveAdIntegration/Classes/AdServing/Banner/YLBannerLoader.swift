import PromiseKit
import GoogleMobileAds
import YieldloveExternalConfiguration

class YLBannerLoader {
    
    private let bannerConfiguration: YLBannerConfiguration
    private let bannerFactory: BannerFactory
    
    init(bannerConfiguration: YLBannerConfiguration, bannerFactory: BannerFactory = YLBannerFactory()) {
        self.bannerConfiguration = bannerConfiguration
        self.bannerFactory = bannerFactory
    }
    
    func loadBanner() {
        let publisherDelegate = bannerConfiguration.publisherDelegate
        publisherDelegate.bannerViewDidStartLoadingAd?()
        getConfigurableAdUnitData()
            .map(transformAdUnitData)
            .map(callLoad)
            .catch(handleError)
    }
    
    private func callLoad(ylAdUnitData: YLAdUnitData) {
        let banner = createBanner(ylAdUnitData: ylAdUnitData)
        banner.load(adSlotId: bannerConfiguration.adSlotId, ylAdUnitData: ylAdUnitData)
    }
    
    private func createBanner(ylAdUnitData: YLAdUnitData) -> LoadableBanner {
        return bannerFactory.make(ylAdUnitData: ylAdUnitData, bannerConfiguration: bannerConfiguration)
    }
    
    private func getConfigurableAdUnitData() -> Promise<ConfigurableAdUnitData> {
        let config = bannerConfiguration.config
        return config.configurationManager.getAdUnitData(publisherAdSlot: bannerConfiguration.adSlotId, adType: .bannerAd)
    }
    
    private func transformAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) throws -> YLAdUnitData {
        return try YLAdUnitDataTransformer.transformBannerAdUnitData(configurableAdUnitData: configurableAdUnitData)
    }
    
    private func handleError(error: Error) {
        let ylBannerView = YLBannerView(bannerView: GADBannerView())
        let publisherDelegate = bannerConfiguration.publisherDelegate
        publisherDelegate.bannerView?(ylBannerView, didFailToReceiveAdWithError: error)
    }
    
}
