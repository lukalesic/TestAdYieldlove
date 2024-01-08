import CoreGraphics

public struct BannerSizes {
    public init(bannerSizes: [CGSize] = [], gadBannerSizes: [String] = []) {
        self.bannerSizes = bannerSizes
        self.gadBannerSizes = gadBannerSizes
    }
    
    public var bannerSizes: [CGSize] = []
    public var gadBannerSizes: [String] = []
}
