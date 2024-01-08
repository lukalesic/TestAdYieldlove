import Foundation

@objc public enum YieldloveConsentError: Int, Error {
    case consentRequestFailed
}

extension YieldloveConsentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .consentRequestFailed:
            return NSLocalizedString("Consent request failed. Enable debug mode for more info.", comment: "consentRequestFailed")
        }
    }
}
