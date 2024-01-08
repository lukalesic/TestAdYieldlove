struct ContextualTargetingConstants {
    static let iabVendorConsentsKey = "IABTCF_VendorConsents"
    static let iabPurposeConsentsKey = "IABTCF_PurposeConsents"
    static let iabVendorLegitimateInterestKey = "IABTCF_VendorLegitimateInterests"
    static let iabPurposeLegitimateInterestKey = "IABTCF_PurposeLegitimateInterests"
    static let iabPublisherRestrictionsKeyPattern = "IABTCF_PublisherRestrictions{ID}"
    static let iabPublisherRestrictionsPlaceholder = "{ID}"
    static let iabAdexVendorId = 44
    static let iabVendorIdTheAdexZeroBased = 43
    static let iabStroeerVendorId = 1057
    static let iabPurposeStoreAccessInformationOnDeviceId = 1
    static let iabPurposeSelectBasicAdsId = 2
    static let idfaInvalidString = "00000000-0000-0000-0000-000000000000"
    static let stroeerCustomerIdWithTheAdex = 285
    static let stroeerTagIdWithTheAdex = 6658
    static let contentURLParameterName = "stroeer_contenturl"
    static let theAdexApiBaseUrl = "https://api.theadex.com/collector/v1/ifa/c/"
    // swiftlint:disable line_length
    static let theAdexApiUrlTemplate = "\(theAdexApiBaseUrl)\(ContextualTargetingConstants.stroeerCustomerIdWithTheAdex)/t/\(ContextualTargetingConstants.stroeerTagIdWithTheAdex)/request?ifa_type=idfa&ifa=#idfa#"
    // swiftlint:enable line_length
    static let theAdexApiUrlTemplateIdfaPlaceholder = "#idfa#"
    static let symbolOfBinaryPermission: Character = "1"
    static let nonFlexiblePurpose1Id = 1
    static let iabTCStringKey = "IABTCF_TCString"
}
