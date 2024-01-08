import GoogleMobileAds

public class AdSlotConfigurationError: NSError {
    
    public init(_ error: Error) {
        
        var msg = YLConstants.adSlotConfigurationErrorMessage
        msg += error.localizedDescription
        
        super.init(domain: "Yieldlove", code: 0, userInfo: [
            NSLocalizedDescriptionKey: msg
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias RawValue = NSError
}
