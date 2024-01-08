public class ExternalConfigurationManagerBuilder {
    
    public static let instance = ExternalConfigurationManagerBuilder()
    
    public var debug = false
    public var appName: String?
    public var externalConfigurationManager: ConfigurationManager = build()
    
    private static func build() -> ConfigurationManager {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let requestSender = HttpRequestSender(configuration: configuration)
        let fetcher = HttpExternalConfigFetcher(requestSender: requestSender)
        let urlBuilder = UrlBuilder()
        let parser = ExternalConfigurationParser()
        let configDao = ConfigUserDefaultsDao()
        let timestampDao = ConfigTimestampUserDefaultsDao()
        
        let configurationUpdater = ConfigurationUpdater(
                fetcher: fetcher,
                urlBuilder: urlBuilder,
                configDao: configDao,
                timestampDao: timestampDao
        )
        
        return ExternalConfigurationManager(
            parser: parser,
            configurationUpdater: configurationUpdater,
            configDao: configDao,
            timestampDao: timestampDao
        )
    }
}
