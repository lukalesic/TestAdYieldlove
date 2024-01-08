public protocol ConfigurableConsentData {
    var accountId: String { get set }
    var isActive: Bool { get set }
    var propertyId: Int { get set }
    var propertyName: String { get set }
    var privacyManagerId: String { get set }
}
