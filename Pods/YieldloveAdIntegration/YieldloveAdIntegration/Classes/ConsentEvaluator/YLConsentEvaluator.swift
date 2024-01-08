protocol ConsentEvaluator {
    func consentGivenFor(vendorId: Int, purposeId: Int) -> Bool
    func legitimateInterestAcceptedFor(vendorId: Int, purposeId: Int) -> Bool
}

class YLConsentEvaluator: ConsentEvaluator {
    
    private let consentReader: ConsentReader
    
    init(consentReader: ConsentReader = YLConsentReader()) {
        self.consentReader = consentReader
    }
    
    func consentGivenFor(vendorId: Int, purposeId: Int) -> Bool {
        return hasVendorAndPurposeConsent(vendorId: vendorId, purposeId: purposeId)
    }
    
    func legitimateInterestAcceptedFor(vendorId: Int, purposeId: Int) -> Bool {
        let consent = hasVendorAndPurposeConsent(vendorId: vendorId, purposeId: purposeId)
        let legitimateInterest = hasVendorAndPurposeLegitimateInterest(vendorId: vendorId, purposeId: purposeId)
        return consent || legitimateInterest
    }
    
    private func hasVendorAndPurposeConsent(vendorId: Int, purposeId: Int) -> Bool {
        let vendorConsent = self.consentReader.getVendorConsent()
        let purposeConsent = self.consentReader.getPurposeConsent()
        
        let vendorConsentGiven = consentBinaryStringContains(vendorId, vendorConsent)
        let purposeConsentGiven = consentBinaryStringContains(purposeId, purposeConsent)
        
        return vendorConsentGiven && purposeConsentGiven
    }
    
    private func hasVendorAndPurposeLegitimateInterest(vendorId: Int, purposeId: Int) -> Bool {
        let vendorLegitimateInterest = self.consentReader.getVendorLegitimateInterest()
        let purposeLegitimateInterest = self.consentReader.getPurposeLegitimateInterest()
        
        let vendorLegitimateInterestAccepted = consentBinaryStringContains(vendorId, vendorLegitimateInterest)
        let purposeLegitimateInterestAccepted = consentBinaryStringContains(purposeId, purposeLegitimateInterest)
        return vendorLegitimateInterestAccepted && purposeLegitimateInterestAccepted
    }
    
    private func consentBinaryStringContains(_ id: Int, _ binaryString: String?) -> Bool {
        if let consentString = binaryString, !consentString.isEmpty, consentString.count >= id {
            let value = getValueFor(id, consentString)
            return value == ContextualTargetingConstants.symbolOfBinaryPermission
        }
        return false
    }
    
    private func getValueFor(_ vendorId: Int, _ binaryString: String) -> Character {
        let offset = vendorId - 1
        return binaryString[binaryString.index(binaryString.startIndex, offsetBy: offset)]
    }
    
}
