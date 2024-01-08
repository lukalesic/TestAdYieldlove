import PromiseKit

class ConfigurationUpdater {
    
    let fetcher: ConfigFetcher
    let urlBuilder: ConfigurationUrlBuilder
    let configDao: ConfigDao
    let timestampDao: ConfigTimestampDao
    
    init(fetcher: ConfigFetcher,
         urlBuilder: ConfigurationUrlBuilder,
         configDao: ConfigDao,
         timestampDao: ConfigTimestampDao) {
        self.fetcher = fetcher
        self.urlBuilder = urlBuilder
        self.configDao = configDao
        self.timestampDao = timestampDao
    }
    
    public func updateConfig() -> Promise<String> {
        firstly {
            getConfigUrl()
        }.then { (url: String) in
            self.fetcher.fetch(url: url)
        }.then { (fetchedConfig: String?) in
            self.writeConfig(configJSON: fetchedConfig)
        }
    }
    
    private func getConfigUrl() -> Promise<String> {
        return Promise { seal in
            do {
                let url = try self.urlBuilder.getExternalConfigUrl()
                seal.fulfill(url)
            } catch {
                seal.reject(error)
            }
        }
    }
    
    private func writeConfig(configJSON: String?) -> Promise<String> {
        return Promise { seal in
            if let safeConfigJSON = configJSON {
                self.configDao.write(configJSON: safeConfigJSON)
                self.timestampDao.write(timestamp: self.getNowTime())
                seal.fulfill(safeConfigJSON)
            } else {
                seal.reject(ConfigurationManagerError.askedToWriteNilConfig)
            }
        }
    }
    
    private func getNowTime() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
    
}
