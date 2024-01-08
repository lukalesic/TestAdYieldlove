struct PrebidConstants {
    
    enum KeyValueTargeting: String, CaseIterable {
        case bidder = "hb_bidder"
        case env = "hb_env"
        case pb = "hb_pb"
        case cache_id = "hb_cache_id"
        case size = "hb_size"
    }
    
    static let mappingDict: [KeyValueTargeting: String] = [
        .bidder: "yl_app_bidder",
        .env: "yl_app_env",
        .pb: "yl_app_pb",
        .cache_id: "yl_app_cache_id",
        .size: "yl_app_size"
    ]
    
    enum MetaTag: String, CaseIterable {
        case bidSuccess = "yieldlove_sucbid"
        case meta = "yieldlove_meta"
        case resultCode = "yieldlove_pbs_result"
    }
    
    static let productionPrebidServerUrl = "https://s2s.yieldlove-ad-serving.net/openrtb2/auction"
    static let prebidTimeoutMillis = 1000
    
    static func getTranslatedKey(key: KeyValueTargeting) -> String? {
        return mappingDict[key]
    }
}
