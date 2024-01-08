class YLDebugInfo {
    
    var appName: String
    var publisherCallString: String
    var adUnitData: YLAdUnitData
    var iabTCString: String?
    
    init(_ appName: String, _ publisherCallString: String, _ adUnitData: YLAdUnitData, _ iabTCString: String? = nil) {
        self.appName = appName
        self.publisherCallString = publisherCallString
        self.adUnitData = adUnitData
        self.iabTCString = iabTCString
    }
}
