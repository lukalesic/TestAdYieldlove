import Foundation

enum YLConsentManagerFactoryError: Error {
    case consentExternalConfigurationIsNotActive
    case consentConfigurationIncorrect
}

extension YLConsentManagerFactoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .consentExternalConfigurationIsNotActive:
            return "Consent feature is not enabled in External configuration for this app."
        case .consentConfigurationIncorrect:
            return "Consent configuration is incorrect, will not request consent data."
        }
        
    }
}
