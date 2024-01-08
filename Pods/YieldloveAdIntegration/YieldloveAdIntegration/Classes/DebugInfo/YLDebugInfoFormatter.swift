import UIKit

class YLDebugInfoFormatter {
    
    static func getDebugInfoText(_ debugInfo: YLDebugInfo) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(getSectionLabel("Ad Slot Info"))
        result.append(getAdSlotInfo(debugInfo))
        result.append(getSectionLabel("General Info"))
        result.append(getGeneralInfo(debugInfo))
        return result
    }
    
    static func getSectionLabel(_ heading: String) -> NSAttributedString {
        let font = UIFont.boldSystemFont(ofSize: 24)
        let attributes = [NSAttributedString.Key.font: font]
        return NSAttributedString(string: heading, attributes: attributes)
    }
    
    static func getSectionText(_ text: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let paragraphAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: text, attributes: paragraphAttributes)
    }
    
    static func getAdSlotInfo(_ debugInfo: YLDebugInfo) -> NSAttributedString {
        let adUnitData = debugInfo.adUnitData
        let adSlotInfo = """
        
        Ad Unit: \(adUnitData.adUnit)
        Sizes: \(YLAdSizeCollection(sizes: adUnitData.bannerSizes).description)
        Key-values: \(adUnitData.keyValueTargeting.description)
        GDPR String: \(debugInfo.iabTCString ?? "missing TC string")
        Auto Refresh: \(adUnitData.autoRefreshTimeMs != nil)
        Gam Response Id: \(adUnitData.responseIdentifier ?? "unknown")
        \n
        """
        return getSectionText(adSlotInfo)
    }
    
    static func getGeneralInfo(_ debugInfo: YLDebugInfo) -> NSAttributedString {
        let adUnitData = debugInfo.adUnitData
        let generalInfo = """
        
        Prebid Active: \(!adUnitData.skipPrebid)
        YL AccountId: \(adUnitData.accountId ?? "unknown")
        YL ConfigId: \(adUnitData.configId)
        
        App Name: \(debugInfo.appName)
        Publisher Call String: \(adUnitData.publisherCallString ?? "unknown")
        """
        return getSectionText(generalInfo)
    }
}
