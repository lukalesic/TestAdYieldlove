class ConfigurationCacheTtl {

    static func isConfigTooOld(syncInterval: Int, lastFetchedInterval: Int ) -> Bool {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        let timeWhenConfigIsTooOld = lastFetchedInterval + syncInterval
        return timeWhenConfigIsTooOld < now
    }
}
