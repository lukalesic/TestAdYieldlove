import GoogleMobileAds

class YLAdSizeCollection: CustomStringConvertible {
    
    var adSizes: [AdSize] = []
    var description: String {
        return adSizes.reduce("", { result, adSize in
            let sizeAsString = adSize.size.debugDescription
            return result == "" ? sizeAsString : result + ", " + sizeAsString
        })
    }
    
    init(sizes: [AdSize]) {
        self.adSizes = sizes
    }
    
    func contains(size: AdSize) -> Bool {
        return self.adSizes.contains { areAdSizesEqual(lhs: $0, rhs: size) }
    }
    
    func areAdSizesEqual(lhs: AdSize, rhs: AdSize) -> Bool {
        return lhs.size == rhs.size
    }
    
    func getSizes() -> NSArray {
        return self.adSizes.map { NSValueFromGADAdSize($0) } as NSArray
    }
    
    public func isEqual(collection: YLAdSizeCollection) -> Bool {
        return collection.adSizes.allSatisfy({self.contains(size: $0)}) && (self.adSizes.count == collection.adSizes.count)
    }
    
}
