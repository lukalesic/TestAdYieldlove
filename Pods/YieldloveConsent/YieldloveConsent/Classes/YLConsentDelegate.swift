import ConsentViewController
import PromiseKit

class YLConsentDelegate: SPDelegate {
    
    weak var publisherDelegate: ConsentDelegate?
    weak var publisherViewController: UIViewController?
    
    init(publisherViewController: UIViewController?, publisherDelegate: ConsentDelegate?) {
        self.publisherViewController = publisherViewController
        self.publisherDelegate = publisherDelegate
    }
    
    init(publisherDelegate: ConsentDelegate?) {
        self.publisherDelegate = publisherDelegate
    }
    
    func onAction(_ action: SPAction, from controller: UIViewController) {
        publisherDelegate?.onAction?(action: action)
    }
    
    func onSPUIReady(_ controller: UIViewController) {
        if controller.isBeingPresented {
            return
        }
        controller.modalPresentationStyle = .overFullScreen
        publisherDelegate?.onSPUIReady?()
        publisherViewController?.present(controller, animated: true)
    }
    
    func onSPUIFinished(_ controller: UIViewController) {
        publisherViewController?.dismiss(animated: true)
        publisherDelegate?.onSPUIFinished?()
    }

    public func onConsentReady(userData: SPUserData) {
        publisherDelegate?.onConsentReady?(consents: userData)
    }

    func onError(error: SPError) {
        if YLConsent.debug {
            print("SourcePoint consent error: \(error)")
        }
        let myError = YieldloveConsentError.consentRequestFailed
        publisherDelegate?.onError?(error: myError)
    }
}
