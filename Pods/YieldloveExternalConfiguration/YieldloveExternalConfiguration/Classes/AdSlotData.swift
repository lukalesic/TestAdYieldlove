enum AdSlotType: String {
    case sdi = "SDI"
    case flexible = "flexible"
}

struct AdSlotData {
    
    // parts of publisher call string
    var zone: String? // e.g. "homepage"
    var zone2: String? // e.g. "rubrik"
    var pageType: String? // e.g. "tech"
    var adSlot: String? // e.g. "b1"
    
    var adType: AdType
    
    // full ad slot name
    var adSlotId: String // e.g. "homepage_rubrik_tech_b1" or "appname_m_android_300x250_2"
    
    var adSlotType: AdSlotType = AdSlotType.sdi // e.g. "SDI" or "flexible"
}
