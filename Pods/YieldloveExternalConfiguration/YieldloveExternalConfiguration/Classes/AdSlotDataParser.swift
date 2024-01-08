import PromiseKit

struct AdSlotDescriptor {
    var adSlotId: String
    var adType: AdType
    var adSlotType: AdSlotType?
}

class AdSlotDataParser {
    static func getAdSlotData(adSlotDescriptor: AdSlotDescriptor) throws -> AdSlotData {
        if adSlotDescriptor.adSlotId == "" {
            throw ConfigurationParsingError.unableToParseAdSlotId
        } else if adSlotDescriptor.adSlotType == AdSlotType.sdi {
            let adSlotIdParts = adSlotDescriptor.adSlotId.split(separator: "_")
            if let firstPart = adSlotIdParts.first, let lastPart = adSlotIdParts.last {
                return AdSlotData(
                    zone: String(firstPart),
                    zone2: self.getZone2(parts: adSlotIdParts),
                    pageType: self.getPageType(parts: adSlotIdParts),
                    adSlot: String(lastPart),
                    adType: adSlotDescriptor.adType,
                    adSlotId: adSlotDescriptor.adSlotId
                )
            } else {
                throw ConfigurationParsingError.unableToParseZonesInAdSlotId
            }
        } else {
            return AdSlotData(
                adType: adSlotDescriptor.adType,
                adSlotId: adSlotDescriptor.adSlotId,
                adSlotType: AdSlotType.flexible
            )
        }
    }
    
    static func getZone2(parts: [String.SubSequence]) -> String? {
        return parts.count > 3 ? String(parts[1]) : nil
    }
    
    static func getPageType(parts: [String.SubSequence]) -> String? {
        return parts.count > 2 ? String(parts[parts.endIndex - 2]) : nil
    }
}
