import GoogleMobileAds

protocol GamBannerViewFactory {
    func makeGAMBannerView(adUnitData: YLAdUnitData, delegate: YLAdDelegate) -> GAMBannerView
}

class YLGamBannerViewFactory: GamBannerViewFactory {
    func makeGAMBannerView(adUnitData: YLAdUnitData, delegate: YLAdDelegate) -> GAMBannerView {
        let gamBannerView = GAMBannerView(adSize: adUnitData.bannerSizes[0])
        gamBannerView.validAdSizes = []
        for adSize in adUnitData.bannerSizes {
            gamBannerView.validAdSizes?.append(NSValueFromGADAdSize(adSize))
        }
        
        gamBannerView.rootViewController = delegate.publisherViewController
        gamBannerView.delegate = delegate
        gamBannerView.adUnitID = adUnitData.adUnit
        
        return gamBannerView
    }
}
