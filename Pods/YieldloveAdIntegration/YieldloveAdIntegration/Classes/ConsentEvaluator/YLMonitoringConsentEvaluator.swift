protocol MonitoringConsentEvaluator {
    func canReportTimeSessions() -> Bool
}

class YLMonitoringConsentEvaluator: MonitoringConsentEvaluator {
    
    let restrictionsResolver: RestrictionsResolver
    
    let iabStroeerSSPVendorId = MonitoringConstants.iabStroeerSSPVendorId
    let iabStroeerVendorId = MonitoringConstants.iabStroeerVendorId
    let iabPurposeStoreAccessInformationOnDeviceId = MonitoringConstants.iabPurposeStoreAccessInformationOnDeviceId
    let iabPurposeProductDevelopmentId = MonitoringConstants.iabPurposeProductDevelopmentId
    
    init(resolver: RestrictionsResolver = YLRestrictionsResolver()) {
        self.restrictionsResolver = resolver
    }
    
    func canReportTimeSessions() -> Bool {
        let stroeerSSPPurpose1 = resolve(iabStroeerSSPVendorId, iabPurposeStoreAccessInformationOnDeviceId)
        let stroeerPurpose1 = resolve(iabStroeerVendorId, iabPurposeStoreAccessInformationOnDeviceId)
        let stroeerSSPPurpose10 = resolve(iabStroeerSSPVendorId, iabPurposeProductDevelopmentId)
        let stroeerPurpose10 = resolve(iabStroeerVendorId, iabPurposeProductDevelopmentId)
        
        return stroeerSSPPurpose1 && stroeerSSPPurpose10 && stroeerPurpose1 && stroeerPurpose10
    }
    
    private func resolve(_ vendorId: Int, _ purposeId: Int) -> Bool {
        return self.restrictionsResolver.resolve(vendorId: vendorId, purposeId: purposeId)
    }
    
}
