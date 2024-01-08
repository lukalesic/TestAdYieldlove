import CoreGraphics

class AdSizesParser {
    
    static func getSizes(_ config: [String: Any], _ adSlotData: AdSlotData) throws -> BannerSizes {
        var sizes = getSizesBasedOnFormat(config, adSlotData)
        sizes.bannerSizes.append(contentsOf: getSizesFromAdSlot(config, adSlotData))
        
        if sizes.bannerSizes.count == 0 && sizes.gadBannerSizes.count == 0 && (adSlotData.adType == AdType.bannerAd) {
            throw ConfigurationParsingError.missingBannerSize
        }
        
        return sizes
    }
    
    private static func getGADSizes(_ dfpSizes: [String: Any]) -> [String] {
        var sizes: [String] = []
        if let iOSDfpSizes = dfpSizes["iosAdSizes"] as? [String] {
            for size in iOSDfpSizes {
                if isGADSizeValueDeprecated(size) {
                    sizes.append(String(size.dropFirst()))
                } else {
                    sizes.append(size)
                }
            }
        }
        return sizes
    }
    
    private static func getSizesBasedOnFormat(_ config: [String: Any], _ adSlotData: AdSlotData) -> BannerSizes {
        var sizes = BannerSizes()
        if let formats = config["formats"] as? [String: Any] {
            for (_, format) in formats {
                let (customSizes, gadSizes) = getSizesFromFormat(format, adSlotData)
                sizes.bannerSizes.append(contentsOf: customSizes)
                sizes.gadBannerSizes.append(contentsOf: gadSizes)
            }
        }
        return sizes
    }
    
    private static func getSizesFromFormat(_ format: Any, _ adSlotData: AdSlotData) -> ([CGSize], [String]) {
        if let formatAvailableOnAdSlots = format as? [String: Any] {
            if let active = formatAvailableOnAdSlots["active"] as? Bool, active {
                if let availableOn = formatAvailableOnAdSlots["availableOn"] as? [String] {
                    if let adSlot = ExternalConfigurationParser.getAdSlotBasedOnType(adSlotData: adSlotData), availableOn.contains(adSlot) {
                        if let dfpSizes = formatAvailableOnAdSlots["dfpSizes"] as? [String: Any] {
                            return (getCustomSizes(dfpSizes), getGADSizes(dfpSizes))
                        }
                    }
                }
            }
        }
        return ([], [])
    }
    
    private static func getCustomSizes(_ dfpSizes: [String: Any]) -> [CGSize] {
        var sizes: [CGSize] = []
        if let customSizes = dfpSizes["customAdSizes"] as? [Any] {
            for size in customSizes {
                if let customSize = size as? [String: Any] {
                    if let width = customSize["w"] as? Int, let height = customSize["h"] as? Int {
                        sizes.append(CGSize(width: width, height: height))
                    }
                }
            }
        }
        return sizes
    }
    
    private static func getSizesFromAdSlot(_ config: [String: Any], _ adSlotData: AdSlotData) -> [CGSize] {
        var sizes: [CGSize] = []
        if let adSlotBasedOnType = ExternalConfigurationParser.getAdSlotBasedOnType(adSlotData: adSlotData) {
            if let adSlots = config["adSlots"] as? [String: Any] {
                if let adSlot = adSlots[adSlotBasedOnType] as? [String: Any] {
                    sizes.append(contentsOf: getCustomSizes(adSlot))
                }
            }
        }
        return sizes
    }
    
    private static func isGADSizeValueDeprecated(_ size: String) -> Bool {
        return size.prefix(1) == "k"
    }
}
