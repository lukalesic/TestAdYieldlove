import PromiseKit

extension Promise where T == Any {
    
    public static func runOnAnotherThread<T>(call: @escaping () throws -> T) -> Promise<T> {
        return DispatchQueue(label: "background-promise", qos: .userInitiated).async(.promise) {
            return try call()
        }
    }
    
}

public class ExternalConfigurationManager: ConfigurationManager {

    let parser: ConfigurationParser
    let configDao: ConfigDao
    let timestampDao: ConfigTimestampDao
    let configurationUpdater: ConfigurationUpdater

    init(parser: ConfigurationParser,
         configurationUpdater: ConfigurationUpdater,
         configDao: ConfigDao,
         timestampDao: ConfigTimestampDao
    ) {
        self.parser = parser
        self.configDao = configDao
        self.timestampDao = timestampDao
        self.configurationUpdater = configurationUpdater
    }

    public func getAdUnitData(publisherAdSlot: String, adType: AdType) -> Promise<ConfigurableAdUnitData> {
        if let configInUserDefaults = self.configDao.read() {
            return self.getAdUnitDataAndFetchIfOld(adSlotName: publisherAdSlot, adType: adType, localConfig: configInUserDefaults)
        } else {
            return self.fetchConfigAndUseAdUnitData(adSlotName: publisherAdSlot, adType: adType)
        }
    }

    public func getConsentData(overrideProperties: String? = nil) -> Promise<ConfigurableConsentData> {
        if let configInUserDefaults = self.configDao.read() {
            return self.getConsentDataAndFetchIfOld(localConfig: configInUserDefaults, overrideProperties: overrideProperties)
        } else {
            return self.fetchConfigAndUseConsentData(overrideProperties: overrideProperties)
        }
    }
    
    public func getMonitoringData() -> Promise<MonitoringData> {
        if let configInUserDefaults = self.configDao.read() {
            return self.getMonitoringDataAndFetchIfOld(localConfig: configInUserDefaults)
        } else {
            return self.fetchConfigAndUseMonitoringData()
        }
    }

    public func clearConfigurationCache() {
        self.configDao.delete()
    }
    
    private func getAdUnitDataAndFetchIfOld(adSlotName: String, adType: AdType, localConfig: String) -> Promise<ConfigurableAdUnitData> {
        self.loadCurrentConfigInBackground(localConfig: localConfig)
        return self.getAdUnitData(adSlotName: adSlotName, adType: adType, configJSON: localConfig)
    }
    
    private func getConsentDataAndFetchIfOld(localConfig: String, overrideProperties: String? = nil) -> Promise<ConfigurableConsentData> {
        self.loadCurrentConfigInBackground(localConfig: localConfig)
        return self.getConsentData(configJSON: localConfig, overrideProperties: overrideProperties)
    }
    
    private func getMonitoringDataAndFetchIfOld(localConfig: String) -> Promise<MonitoringData> {
        self.loadCurrentConfigInBackground(localConfig: localConfig)
        return self.getMonitoringData(configJSON: localConfig)
    }
    
    private func fetchConfigAndUseAdUnitData(adSlotName: String, adType: AdType) -> Promise<ConfigurableAdUnitData> {
        return self.configurationUpdater.updateConfig().then { fetchedConfig in
            self.getAdUnitData(adSlotName: adSlotName, adType: adType, configJSON: fetchedConfig)
        }
    }
    
    private func fetchConfigAndUseConsentData(overrideProperties: String? = nil) -> Promise<ConfigurableConsentData> {
        return self.configurationUpdater.updateConfig().then { fetchedConfig in
            self.getConsentData(configJSON: fetchedConfig, overrideProperties: overrideProperties)
        }
    }

    private func fetchConfigAndUseMonitoringData() -> Promise<MonitoringData> {
        return self.configurationUpdater.updateConfig().then { fetchedConfig in
            self.getMonitoringData(configJSON: fetchedConfig)
        }
    }
    
    private func getAdUnitData(adSlotName: String, adType: AdType, configJSON: String) -> Promise<ConfigurableAdUnitData> {
        return Promise.runOnAnotherThread {
            try self.parser.parseAdUnit(adSlotName: adSlotName, configJSON: configJSON, adType: adType)
        }
    }
    
    private func getConsentData(configJSON: String, overrideProperties: String! = nil) -> Promise<ConfigurableConsentData> {
        return Promise.runOnAnotherThread {
            try self.parser.getConsentData(configJSON: configJSON, overrideProperties: overrideProperties)
        }
    }
    
    private func getMonitoringData(configJSON: String) -> Promise<MonitoringData> {
        return Promise.runOnAnotherThread {
            try self.parser.getMonitoringData(configJSON: configJSON)
        }
    }

    private func loadCurrentConfigInBackground(localConfig: String) {
        Promise.runOnAnotherThread {
            try self.parser.getSyncInterval(configJSON: localConfig)
        }.then { syncInterval in
            self.getLocalConfigOrFetchIfTooOld(syncInterval: syncInterval, localConfig: localConfig)
        }.catch { error in
            Logger.debug(message: "External Configuration Manager method \(#function) failed with error \(error.localizedDescription)")
        }
    }
    
    private func getLocalConfigOrFetchIfTooOld(syncInterval: Int, localConfig: String) -> Promise<String> {
        let lastFetchTimestamp = self.timestampDao.read()
        let isConfigTooOld = ConfigurationCacheTtl.isConfigTooOld(syncInterval: syncInterval, lastFetchedInterval: lastFetchTimestamp)
        return isConfigTooOld ? self.configurationUpdater.updateConfig() : Promise.value(localConfig)
    }

}
