@objc public class CustomConsentData: NSObject {
    
    public var vendors: [String] = []
    public var categories: [String] = []
    public var legIntCategories: [String] = []
    
    public init(
        vendors: [String],
        categories: [String],
        legIntCategories: [String]
    ) {
        self.vendors = vendors
        self.categories = categories
        self.legIntCategories = legIntCategories
    }
}
