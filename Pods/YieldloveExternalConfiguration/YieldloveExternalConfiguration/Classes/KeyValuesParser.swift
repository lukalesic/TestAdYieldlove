class KeyValuesParser {
    
    static func getKeyValues(_ config: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var requestKeyValues: [String: String] = [:]
        
        if adSlotData.adSlotType == AdSlotType.sdi {
            if let zonesAndPageTypes = config["zonesAndPageTypes"] as? [String: Any] {
                requestKeyValues = requestKeyValues.merging(getLevel1KeyValues(zonesAndPageTypes, adSlotData)) { (current, _) in current }
                requestKeyValues = requestKeyValues.merging(getLevel2KeyValues(zonesAndPageTypes, adSlotData)) { (current, _) in current }
                requestKeyValues = requestKeyValues.merging(getPageTypeKeyValues(zonesAndPageTypes, adSlotData)) { (current, _) in current }
            }
            requestKeyValues = requestKeyValues.merging(getAdSlotKeyValues(config, adSlotData)) { (current, _) in current }
        } else {
            requestKeyValues = requestKeyValues.merging(getAdSlotIdKeyValues(config, adSlotData)) { (current, _) in current }
        }
        
        return requestKeyValues
    }
    
    fileprivate static func getLevel1KeyValues(_ zonesAndPageTypes: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var level1KeyValues: [String: String] = [:]
        if let level1 = zonesAndPageTypes["level1"] as? [String: Any] {
            guard let zone = adSlotData.zone else {
                return level1KeyValues
            }
            if let node = level1[zone] as? [String: Any] {
                level1KeyValues = getKeyValues(node: node)
            }
        }
        return level1KeyValues
    }
    
    fileprivate static func getLevel2KeyValues(_ zonesAndPageTypes: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var level2KeyValues: [String: String] = [:]
        if let level2 = zonesAndPageTypes["level2"] as? [String: Any] {
            if let safeZone2 = adSlotData.zone2 {
                if let node = level2[safeZone2] as? [String: Any] {
                    level2KeyValues = getKeyValues(node: node)
                }
            }
        }
        return level2KeyValues
    }
    
    fileprivate static func getPageTypeKeyValues(_ zonesAndPageTypes: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var pageTypeKeyValues: [String: String] = [:]
        if let pageTypes = zonesAndPageTypes["pageType"] as? [String: Any] {
            if let safePageType = adSlotData.pageType {
                if let node = pageTypes[safePageType] as? [String: Any] {
                    pageTypeKeyValues = getKeyValues(node: node)
                }
            }
        }
        return pageTypeKeyValues
    }
    
    fileprivate static func getAdSlotKeyValues(_ config: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var adSlotKeyValues: [String: String] = [:]
        if let adSlots = config["adSlots"] as? [String: Any] {
            guard let adSlot = adSlotData.adSlot else {
                return adSlotKeyValues
            }
            if let adSlot = adSlots[adSlot] as? [String: Any] {
                adSlotKeyValues = getKeyValues(node: adSlot)
            }
        }
        return adSlotKeyValues
    }
    
    fileprivate static func getAdSlotIdKeyValues(_ config: [String: Any], _ adSlotData: AdSlotData) -> [String: String] {
        var adSlotIdKeyValues: [String: String] = [:]
        if let adSlots = config["adSlots"] as? [String: Any] {
            if let adSlot = adSlots[adSlotData.adSlotId] as? [String: Any] {
                adSlotIdKeyValues = getKeyValues(node: adSlot)
            }
        }
        return adSlotIdKeyValues
    }
    
    fileprivate static func getKeyValues(node: [String: Any]) -> [String: String] {
        var extractedKeyValues: [String: String] = [:]
        if let keyValues = node["keyValues"] as? [String: String] {
            for (key, value) in keyValues {
                extractedKeyValues[key] = value
            }
        }
        return extractedKeyValues
    }
}
