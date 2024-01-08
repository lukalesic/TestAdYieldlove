import GoogleMobileAds
import YieldloveExternalConfiguration

protocol AdDelegate: AdDelegatePromiseBridge {
    var refreshed: Bool { get }
    var ylBannerView: YLBannerView? { get set }
    func isPublisherDelegateNil() -> Bool
}

class YLAdDelegate: AdDelegatePromiseBridge, AdDelegate {
    
    private let adUnitData: YLAdUnitData
    private let timeEventRecorder: TimeEventRecorder?

    weak var publisherViewController: UIViewController?
    weak var publisherDelegate: YLBannerViewDelegate?
    
    var ylBannerView: YLBannerView?
    private var error: Error?
    private var loadCount = 0
    private var debugLabel: UILabel?
    private var debugInfoPanelDelegate: YLDebugInfoPanelDelegate?
    
    var refreshed: Bool {
        return loadCount > 1
    }
    
    init(gamRequestData: GamRequestData, timeEventRecorder: TimeEventRecorder) {
        self.adUnitData = gamRequestData.adUnitData
        self.publisherViewController = gamRequestData.publisherViewController
        self.publisherDelegate = gamRequestData.publisherDelegate
        self.timeEventRecorder = timeEventRecorder
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        loadCount += 1
        recordGamResponse(timeEventRecorder: timeEventRecorder, error: nil)
        addTripleTapRecognizer(view: bannerView)
        
        let responseInfo = bannerView.responseInfo
        adUnitData.responseIdentifier = responseInfo?.responseIdentifier
        
        let ylBannerView = YLBannerView(bannerView: bannerView)
        ylBannerView.wasRefreshed = refreshed
        if Yieldlove.instance.developerModeEnabled {
            addDebugLabel(bannerView)
        }
        fulfill(value: ylBannerView)

        if publisherViewController == nil {
            return /* ignore event - ad is to be deallocated */
        }

        self.ylBannerView = ylBannerView
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        recordGamResponse(timeEventRecorder: timeEventRecorder, error: error)
        loadCount += 1
        
        let responseInfo = (error as NSError).userInfo[GADErrorUserInfoKeyResponseInfo] as? GADResponseInfo
        adUnitData.responseIdentifier = responseInfo?.responseIdentifier
        
        reject(error: YLError.errorWasReportedByDelegate)
        if publisherViewController == nil {
            return /* ignore event - ad is to be deallocated */
        }

        self.error = error
        self.ylBannerView = YLBannerView(bannerView: bannerView)
        self.ylBannerView?.wasRefreshed = refreshed
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        if publisherViewController == nil {
            return /* ignore event - ad is to be deallocated */
        }
        let banner = YLBannerView(bannerView: bannerView)
        publisherDelegate?.bannerViewWillPresentScreen?(banner)
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        if publisherViewController == nil {
            return /* ignore event - ad is to be deallocated */
        }
        let banner = YLBannerView(bannerView: bannerView)
        publisherDelegate?.bannerViewWillDismissScreen?(banner)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        if publisherViewController == nil {
            return /* ignore event - ad is to be deallocated */
        }
        let banner = YLBannerView(bannerView: bannerView)
        publisherDelegate?.bannerViewDidDismissScreen?(banner)
    }
    
    func isPublisherDelegateNil() -> Bool {
        return publisherDelegate == nil
    }
    
    private func recordGamResponse(timeEventRecorder: TimeEventRecorder?, error: Error?) {
        if let err = error {
            timeEventRecorder?.recordGamRespondedWithError(error: err)
        } else {
            timeEventRecorder?.recordGamRespondedSuccessfully()
        }
    }
}

extension YLAdDelegate: YLDebugInfoPanelDelegate {
    func displayDebugInfoPanel(_ adUnitData: YLAdUnitData) {
        let debugInfoVC = YLDebugInfoViewController(adUnitData)
        publisherViewController?.present(debugInfoVC, animated: true)
    }
    
    private func addDebugLabel(_ bannerView: GADBannerView) {
        var timeToServe = TimeInterval()
        if let session = timeEventRecorder?.session {
            timeToServe = YLTimeSessionCalculator.getServedInTime(session: session)
        }
        let debugLabel = getDebugLabel(adUnitData.publisherCallString, .bannerAd, timeToServe)
        bannerView.addSubview(debugLabel)
        self.debugLabel = debugLabel
        self.debugInfoPanelDelegate = self
    }
    
    private func getDebugLabel(_ adSlotName: String?, _ adType: AdType, _ servedIn: TimeInterval) -> UILabel {
        let debugLabel = UILabel()
        debugLabel.accessibilityIdentifier = "responseInfo"
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.adjustsFontSizeToFitWidth = true
        debugLabel.textColor = UIColor.white
        debugLabel.numberOfLines = 2
        debugLabel.backgroundColor = UIColor(red: 8/255.0, green: 32/255.0, blue: 74/255.0, alpha: 0.6)
        debugLabel.text = getLabelText(adSlotName, adType, servedIn)
        debugLabel.isUserInteractionEnabled = true
        addTapRecognizer(view: debugLabel)
        return debugLabel
    }
    
    private func getLabelText(_ adSlotName: String?, _ adType: AdType, _ servedIn: TimeInterval) -> String {
        let adTypeText = adType == .bannerAd ? "Banner:" : "Instl:"
        return "\(adTypeText) \(adSlotName ?? "")\nServed in: \(String(format: "%.2f", servedIn)) s"
    }
    
    private func addTapRecognizer(view: UIView) {
        let tapAction = #selector(tapFunction)
        let tap = UITapGestureRecognizer(target: self, action: tapAction)
        view.addGestureRecognizer(tap)
    }
    
    @objc private func tapFunction(sender: UITapGestureRecognizer) {
        guard sender.view != nil else { return }
        
        if sender.state == .ended {
            debugInfoPanelDelegate?.displayDebugInfoPanel(adUnitData)
        }
    }
    
    private func addTripleTapRecognizer(view: UIView) {
        let tripleTapAction = #selector(tripleTapFunction)
        let tripleTap = UILongPressGestureRecognizer(target: self, action: tripleTapAction)
        tripleTap.numberOfTouchesRequired = 3
        view.addGestureRecognizer(tripleTap)
    }
    
    @objc private func tripleTapFunction(sender: UILongPressGestureRecognizer) {
        guard sender.view != nil else { return }
        
        if sender.state == .ended {
            let message = "Ad debugging mode has been switched on. Force close the app to switch it back off."
            let alert = UIAlertController(title: "Ad Debugging Mode", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                Yieldlove.instance.developerModeEnabled = true
            }))
            self.publisherViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
