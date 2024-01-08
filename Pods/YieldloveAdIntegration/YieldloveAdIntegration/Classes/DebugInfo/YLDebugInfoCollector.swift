import YieldloveExternalConfiguration

class YLDebugInfoCollector {
    
    private let consentReader: ConsentReader
    
    init(consentReader: ConsentReader = YLConsentReader()) {
        self.consentReader = consentReader
    }
    
    func getDebugInfoText(_ adUnitData: YLAdUnitData) -> NSAttributedString {
        let appName = ExternalConfigurationManagerBuilder.instance.appName ?? "App name not set"
        let debugInfo = YLDebugInfo(appName, "", adUnitData)
        debugInfo.iabTCString = consentReader.getTCString()
        return YLDebugInfoFormatter.getDebugInfoText(debugInfo)
    }
}
