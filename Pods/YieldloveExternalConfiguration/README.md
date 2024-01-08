# YieldloveExternalConfiguration

Pod for fetching configuration of ad slots defined for the app. Publishers pass an `appName` and an `adSlotId`. This pod
fetches actual DFP ad slot names, sizes of ad slots, targeting key-values and corresponding Prebid ad slot ids. This data is used to make actual ad requests to Prebid server and Google’s ad server.

This pod is a transparent dependency for the publishers. It is not useful for anything other than in conjuction with the SDK.

- download a json file from the strooer cdn for the specific publisher
- parse it to determine the configuration for the ad serving
- store the config until its expiration time to save http requests

## Change log

| Version  | Release Date  | Notes  |
|---|---|---|
| 0.15.1  | 1.7.2022  | change url session caching policy |
| 0.15.0  | 30.6.2022  | add clear configuration cache |
| 0.12.0  | 20.5.2022  | solve compiler version warning |
| 0.10.1  | 1.2.2022  | Fix parsing `openRtbApi` |
| 0.10.0  | 28.1.2022  | Allow propertyName and propertyId in SP overrides |
| 0.9.1  | 26.1.2022  | Fix parsing `openRtbApi` |
| 0.9.0  | 25.1.2022  | Parse `openRtbApi` |
| 0.8.0  | 11.1.2022  | Parse Criteo Publisher id |
| 0.7.0  | 25.11.2021  | Support for new GADSizes with the latest GoogleMobileAds SDK version, translation of deprecated GADSizes to the new ones |
| 0.6.8  | 1.11.2021  | Change project structure and build settings to fix Carthage package |
| 0.6.7  | 1.11.2021  | Rebuilding Carthage framework with Xcode 13 - swift 5.5 compatibility |
| 0.6.6  | 11.10.2021  | Rebuilding Carthage framework with Xcode 12 - swift 5.4 version for compatibility |
| 0.6.5  | 8.10.2021  | Problems with Carthage deployment, bugfixe versions up to this are the same as 0.6.0 |
| 0.6.0  | 8.10.2021  | External configuration parsing and returning overrides for consent data when requested |
| 0.5.1  | 6.10.2021  | Give BannerSizes struct a public initializer |
| 0.5.0  | 9.8.2021  | Upgrade Alamofire to v5 |
| 0.4.0  | 16.7.2021  | Read ITunesID from configuration |
| 0.3.0  | 14.7.2021  | Read StoreUrl from configuration |
| 0.2.2  | 12.7.2021  | Changed project structure. YiedloveExternalConfiguration is now a separate Xcode project instead of being a part of YiedloveAdIntegration code project. |
| 0.2.1 | 7.6.2021 | Fixed a bug in the YL GAM flexible structure |
| 0.2.0  | -  | Yieldlove GAM flexible structure implementation  |
