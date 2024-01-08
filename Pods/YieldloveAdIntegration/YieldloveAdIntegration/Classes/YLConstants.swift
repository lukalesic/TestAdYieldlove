// swiftlint:disable line_length

import GoogleMobileAds

struct YLConstants {
    // WARNING: Do not modify version by hand, it's overwritten by deploy script during release
    static let version = "9.5.0"
    static let ylDfpAccountId = "53015287"
    static let exampleBannerAdUnit = "/6499/example/banner"
    static let exampleInterstitialAdUnit = "/6499/example/interstitial"
    static let standardAdSizes = [
        GADAdSizeBanner,
        GADAdSizeLargeBanner,
        GADAdSizeMediumRectangle,
        GADAdSizeFullBanner,
        GADAdSizeLeaderboard,
        GADAdSizeSkyscraper,
        GADAdSizeFluid,
        GADAdSizeInvalid
    ]
    static let adSlotConfigurationErrorMessage = "There was a problem with finding, parsing or applying external configuration for this ad slot (publisher call string)"
    static let errorReporterUrl = "https://mobile-sdk.stroeer-labs.com/api/reporting"
    static let errorReporterApiKey = "NVR16aTdPz1sD5rS7QKK37VUzakVw10Z9fL5EZ6T"
    static let sdkVersionNumberKey = "iosYlSdkVersion"
    static let omidPartnerName = "Google"
    static let omidPartnerVersion = "afma-sdk-i-v8.8.0"
}
