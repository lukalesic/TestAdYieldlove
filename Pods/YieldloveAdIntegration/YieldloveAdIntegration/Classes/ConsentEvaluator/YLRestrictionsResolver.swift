protocol RestrictionsResolver {
    func resolve(vendorId: Int, purposeId: Int) -> Bool
}

enum RestrictionType: Int {
    case NOT_ALLOWED
    case REQUIRE_CONSENT
    case REQUIRE_LEGITIMATE_INTEREST
    case UNDEFINED
}

class YLRestrictionsResolver: RestrictionsResolver {
    
    let consentReader: ConsentReader
    let consentEvaluator: ConsentEvaluator
    
    init(reader: ConsentReader = YLConsentReader(), evaluator: ConsentEvaluator = YLConsentEvaluator()) {
        self.consentReader = reader
        self.consentEvaluator = evaluator
    }
    
    func resolve(vendorId: Int, purposeId: Int) -> Bool {
        let restriction = getPublisherPurposeRestriction(vendorId: vendorId, purposeId: purposeId)
        switch restriction {
        case .REQUIRE_CONSENT:
            return consentEvaluator.consentGivenFor(vendorId: vendorId, purposeId: purposeId)
        case .REQUIRE_LEGITIMATE_INTEREST, .UNDEFINED:
            return handleLegitimateInterestOrUndefined(vendorId, purposeId)
        case .NOT_ALLOWED:
            return false
        }
    }
    
    private func handleLegitimateInterestOrUndefined(_ vendorId: Int, _ purposeId: Int) -> Bool {
        if shouldForceConsentCheck(vendorId: vendorId, purposeId: purposeId) {
            return consentEvaluator.consentGivenFor(vendorId: vendorId, purposeId: purposeId)
        }
        return consentEvaluator.legitimateInterestAcceptedFor(vendorId: vendorId, purposeId: purposeId)
    }
    
    private func shouldForceConsentCheck(vendorId: Int, purposeId: Int) -> Bool {
        return purposeId == ContextualTargetingConstants.nonFlexiblePurpose1Id
    }
    
    private func getPublisherPurposeRestriction(vendorId: Int, purposeId: Int) -> RestrictionType {
        let encodedString = consentReader.getPublisherRestrictionsFor(purposeId: purposeId)
        if let restrictions = encodedString, !restrictions.isEmpty, restrictions.count >= vendorId {
            let offset = convertIdToIndex(vendorId)
            let index = restrictions.index(restrictions.startIndex, offsetBy: offset)
            if let restrictionTypeRawValue = restrictions[index].wholeNumberValue {
                return RestrictionType(rawValue: restrictionTypeRawValue) ?? .UNDEFINED
            }
        }
        return .UNDEFINED
    }
    
    private func convertIdToIndex(_ vendorId: Int) -> Int {
        return vendorId - 1
    }
}
