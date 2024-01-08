import GoogleMobileAds

class YLAdSizeInterpreter {
    
    static let standardSizesDictionary = getStandardSizesAsDictionary()
    
    static func getAsGadSizes(_ cgSizes: [CGSize], _ gadSizes: [String]) -> [AdSize] {
        var sizes: [GADAdSize] = []
        sizes.append(contentsOf: getAsGadSizes(sizes: gadSizes))
        sizes.append(contentsOf: getAsGadSizes(sizes: cgSizes))
        return sizes
    }
    
    fileprivate static func getAsGadSizes(sizes: [CGSize]) -> [GADAdSize] {
        return sizes.map({ GADAdSizeFromCGSize($0) })
    }
    
    fileprivate static func getAsGadSizes(sizes: [String]) -> [GADAdSize] {
        var gadSizes: [GADAdSize] = []
        for size in sizes {
            if let standardSize = standardSizesDictionary[size] {
                gadSizes.append(standardSize)
            }
        }
        return gadSizes
    }
    
    fileprivate static func getStandardSizesAsDictionary() -> [String: GADAdSize] {
        var sizesDictionary: [String: GADAdSize] = [:]
        for size in YLConstants.standardAdSizes {
            sizesDictionary[NSStringFromGADAdSize(size)] = size
        }
        return sizesDictionary
    }
}
