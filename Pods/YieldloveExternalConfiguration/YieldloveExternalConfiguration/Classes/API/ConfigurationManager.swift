import PromiseKit

public protocol ConfigurationManager {

    func getAdUnitData(publisherAdSlot: String, adType: AdType) -> Promise<ConfigurableAdUnitData>

    func getConsentData(overrideProperties: String?) -> Promise<ConfigurableConsentData>
    
    func getMonitoringData() -> Promise<MonitoringData>

    func clearConfigurationCache() -> Void
}
