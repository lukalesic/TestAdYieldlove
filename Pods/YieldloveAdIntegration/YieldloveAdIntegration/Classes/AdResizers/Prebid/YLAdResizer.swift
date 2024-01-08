import GoogleMobileAds
import PromiseKit

typealias AdResizeCompletion = () -> Void

protocol AdResizer {
    func resizeAd(banner: YLBannerView, completion: AdResizeCompletion?)
}

class YLAdResizer: AdResizer {
    
    func resizeAd(banner: YLBannerView, completion: AdResizeCompletion?) {
        guard let bannerAd = banner.getBannerView() as? GAMBannerView else {
            completion?()
            return
        }
        _ = self.getWinnerSize(ylBannerView: banner).done { size in
            if let validSize = size {
                bannerAd.resize(GADAdSizeFromCGSize(validSize))
            }
            completion?()
        }
    }
    
    private func getWinnerSize(ylBannerView: YLBannerView) -> Promise<CGSize?> {
        return AdWinnerAnalyzer.instance.getWinner(ylBannerView: ylBannerView).map { winner in
            switch winner {
            case .Prebid:
                return ylBannerView.getPrebidAdSize()
            case .Criteo:
                return ylBannerView.getCriteoAdSize()
            case .GAM:
                return nil
            }
        }
    }
    
}
