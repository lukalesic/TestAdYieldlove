import ConsentViewController

@objc public protocol ConsentDelegate {
    
    /// called when there's a consent Message to be shown or before the PM is shown
    @objc optional func onSPUIReady()

    /// called when the consent ui is closed
    @objc optional func onSPUIFinished()

    /// called when we finish getting the consent profile from SourcePoint's endpoints
    @objc optional func onConsentReady(consents: SPUserData)

    /// the `onError` function can be called at any moment during the SDKs lifecycle
    @objc optional func onError(error: YieldloveConsentError)
    
    /// called when the user takes an action in the SP UI
    @objc optional func onAction(action: SPAction)
}
