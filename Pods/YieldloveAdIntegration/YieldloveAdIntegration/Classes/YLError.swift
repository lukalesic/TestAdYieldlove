enum YLError: Error {
    case bannerSizeNotPassed
    case adRequestDataNil
    case cantInitializePrebid
    case cantResizeBanner
    case invalidBannerSize
    case adUnitDataWasNotSet
    case errorWasReportedByDelegate
}
