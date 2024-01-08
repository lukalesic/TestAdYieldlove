protocol AdexConsentEvaluator {
    func canReportToTheAdex() -> Bool
}

class TheAdexConsentEvaluator: AdexConsentEvaluator {
    
    let restrictionsResolver: RestrictionsResolver
    
    let iabAdexVendorId = ContextualTargetingConstants.iabAdexVendorId
    let iabStroeerVendorId = ContextualTargetingConstants.iabStroeerVendorId
    let iabPurposeStoreAccessInformationOnDeviceId = ContextualTargetingConstants.iabPurposeStoreAccessInformationOnDeviceId
    let iabPurposeSelectBasicAdsId = ContextualTargetingConstants.iabPurposeSelectBasicAdsId
    
    init(resolver: RestrictionsResolver = YLRestrictionsResolver()) {
        self.restrictionsResolver = resolver
    }
    
    func canReportToTheAdex() -> Bool {
        let adexPurpose1 = resolve(iabAdexVendorId, iabPurposeStoreAccessInformationOnDeviceId)
        let stroeerPurpose1 = resolve(iabStroeerVendorId, iabPurposeStoreAccessInformationOnDeviceId)
        let adexPurpose2 = resolve(iabAdexVendorId, iabPurposeSelectBasicAdsId)
        let stroeerPurpose2 = resolve(iabStroeerVendorId, iabPurposeSelectBasicAdsId)
        
        return adexPurpose1 && adexPurpose2 && stroeerPurpose1 && stroeerPurpose2
    }
    
    private func resolve(_ vendorId: Int, _ purposeId: Int) -> Bool {
        return self.restrictionsResolver.resolve(vendorId: vendorId, purposeId: purposeId)
    }
}
