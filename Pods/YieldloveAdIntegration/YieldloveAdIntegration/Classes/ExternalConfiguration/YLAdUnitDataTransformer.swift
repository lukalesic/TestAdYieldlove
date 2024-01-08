import YieldloveExternalConfiguration
import PrebidMobile

class YLAdUnitDataTransformer {

    static func transformBannerAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) throws -> YLAdUnitData {
        let adUnitData = transform(configurableAdUnitData: configurableAdUnitData)
        if let sizes = configurableAdUnitData.sizes {
            let sizesAsGamSizes = YLAdSizeInterpreter.getAsGadSizes(sizes.bannerSizes, sizes.gadBannerSizes)
            adUnitData.setAdSizes(sizes: sizesAsGamSizes)
            return adUnitData
        }
        throw YLError.bannerSizeNotPassed
    }
    
    static func transformInterstitialAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) -> YLAdUnitData {
        return transform(configurableAdUnitData: configurableAdUnitData)
    }
    
    static func transformRewardedAdUnitData(configurableAdUnitData: ConfigurableAdUnitData) -> YLAdUnitData {
        return transform(configurableAdUnitData: configurableAdUnitData)
    }
    
    private static func transform(configurableAdUnitData: ConfigurableAdUnitData) -> YLAdUnitData {
        let adUnitData = YLAdUnitData(
            adUnit: configurableAdUnitData.adUnit,
            configId: configurableAdUnitData.configId,
            criteoPublisherId: configurableAdUnitData.criteoPublisherId
        )
        adUnitData.accountId = configurableAdUnitData.accountId
        adUnitData.keyValueTargeting = configurableAdUnitData.keyValueTargeting
        adUnitData.skipPrebid = configurableAdUnitData.skipPrebid
        adUnitData.frameworks = transformOpenRtbApi(configurableAdUnitData.openRtbApi)
        adUnitData.autoRefreshTimeMs = configurableAdUnitData.autoRefreshTimeMs
        adUnitData.storeUrl = configurableAdUnitData.storeUrl
        adUnitData.itunesID = configurableAdUnitData.itunesID
        return adUnitData
    }
    
    private static func transformOpenRtbApi(_ openRtbApi: [Int]?) -> [Signals.Api]? {
        if let frameworks = openRtbApi {
            return frameworks.map { Signals.Api(integerLiteral: $0) }
        }
        return nil
    }
}
