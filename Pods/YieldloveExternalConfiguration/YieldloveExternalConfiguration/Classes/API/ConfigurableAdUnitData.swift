public protocol ConfigurableAdUnitData {
    var adUnit: String { get set }
    var configId: String { get set }
    var sizes: BannerSizes? { get set }
    var keyValueTargeting: [String: String] { get set }
    var accountId: String? { get set }
    var skipPrebid: Bool { get set }
    var criteoPublisherId: String? { get set }
    var storeUrl: String? { get set }
    var itunesID: String? { get set }
    var openRtbApi: [Int]? { get set }
    var autoRefreshTimeMs: Int? { get set }
}
