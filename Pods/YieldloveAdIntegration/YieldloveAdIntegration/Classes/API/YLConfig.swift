import YieldloveExternalConfiguration

protocol Config: AnyObject {
    var appName: String { get }
    var contextualReporter: ContextualTargetingReporter { get }
    var prebidAdUnitFactory: PrebidAdUnitFactory { get }
    var configurationManager: ConfigurationManager { get }
    var bidCollector: BidsCollector { get }
    var remoteReporter: ExceptionReporter { get }
    var refreshTimerFactory: RefreshTimerFactory { get }
    var gamAdLoader: GamAdLoader { get }
    var referenceManager: ReferenceManager { get }
    var sessionsCollector: SessionsCollector { get }
    
    static func getProductionConfig(appName: String) -> Config
}

@objc public class YLConfig: NSObject, Config {

    var appName: String
    var contextualReporter: ContextualTargetingReporter
    var prebidAdUnitFactory: PrebidAdUnitFactory
    var configurationManager: ConfigurationManager
    var bidCollector: BidsCollector
    var remoteReporter: ExceptionReporter
    var refreshTimerFactory: RefreshTimerFactory
    var gamAdLoader: GamAdLoader
    var referenceManager: ReferenceManager
    var sessionsCollector: SessionsCollector

    init(appName: String,
         contextualReporter: ContextualTargetingReporter,
         prebidAdUnitFactory: PrebidAdUnitFactory,
         configurationManager: ConfigurationManager,
         bidCollector: BidsCollector,
         remoteReporter: ExceptionReporter,
         refreshTimerFactory: RefreshTimerFactory,
         gamAdLoader: GamAdLoader,
         referenceManager: ReferenceManager,
         sessionsCollector: SessionsCollector
    ) {
        self.appName = appName
        self.contextualReporter = contextualReporter
        self.prebidAdUnitFactory = prebidAdUnitFactory
        do {
            try self.prebidAdUnitFactory.setPrebidServerUrl()
        } catch {
            print("Could not set URL to production Prebid server")
        }
        self.configurationManager = configurationManager
        self.bidCollector = bidCollector
        self.remoteReporter = remoteReporter
        self.refreshTimerFactory = refreshTimerFactory
        self.gamAdLoader = gamAdLoader
        self.referenceManager = referenceManager
        self.sessionsCollector = sessionsCollector
    }

    static func getProductionConfig(appName: String) -> Config {
        let configurationManager = ExternalConfigurationManagerBuilder.instance.externalConfigurationManager
        let monitoringReporter = HttpMonitoringReporter(
            appName: appName,
            sdkVersion: YLConstants.version,
            apiKey: MonitoringConstants.monitoringReporterApiKey,
            url: MonitoringConstants.monitoringReporterUrl
        )
        return YLConfig(
                appName: appName,
                contextualReporter: YLContextualTargetingDataReporter(),
                prebidAdUnitFactory: YLPrebidAdUnitFactory(),
                configurationManager: configurationManager,
                bidCollector: YLBidsCollector(),
                remoteReporter: YLHttpExceptionReporter(
                        remoteServiceUrl: YLConstants.errorReporterUrl,
                        remoteServiceApiKey: YLConstants.errorReporterApiKey
                ),
                refreshTimerFactory: YLRefreshTimerFactory(),
                gamAdLoader: YLGamAdLoader(bannerViewFactory: YLGamBannerViewFactory()),
                referenceManager: YLReferenceManager(),
                sessionsCollector: YLTimeSessionsCollector(
                    reporter: monitoringReporter,
                    consentEvaluator: YLMonitoringConsentEvaluator(),
                    monitoringDataGetter: configurationManager.getMonitoringData
                )
        )
    }

}
