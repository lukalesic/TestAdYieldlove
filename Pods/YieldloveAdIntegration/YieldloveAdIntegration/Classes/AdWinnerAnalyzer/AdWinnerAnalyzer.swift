import PromiseKit

class AdWinnerAnalyzer {

    static let instance = AdWinnerAnalyzer()

    func getWinner(ylBannerView: YLBannerView) -> Promise<AdWinner> {
        return when(
                fulfilled: creativeContainsPrebidCacheId(ylBannerView: ylBannerView),
                creativeContainsCriteoProperty(ylBannerView: ylBannerView))
                .map { results in
                    if results.0 {
                        return AdWinner.Prebid
                    }
                    if results.1 {
                        return AdWinner.Criteo
                    }
                    return AdWinner.GAM
                }
    }

    private func creativeContains(ylBannerView: YLBannerView, searchString: String?) -> Promise<Bool> {
        return Promise { seal in
            YLCreativeStringFinder.find(ylBannerView.getBannerView(), searchString,
                    success: { _ in seal.fulfill(true) },
                    failure: { _ in seal.fulfill(false) })
        }
    }

    private func creativeContainsPrebidCacheId(ylBannerView: YLBannerView) -> Promise<Bool> {
        return creativeContains(ylBannerView: ylBannerView, searchString: ylBannerView.getPrebidCacheId())
    }

    private func creativeContainsCriteoProperty(ylBannerView: YLBannerView) -> Promise<Bool> {
        return creativeContains(ylBannerView: ylBannerView, searchString: CriteoConstants.displayUrl)
    }

}
