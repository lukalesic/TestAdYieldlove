class UrlBuilder: ConfigurationUrlBuilder {
    var externalConfigUrl: String = ""
    
    func getExternalConfigUrl() throws -> String {
        if let appName = ExternalConfigurationManagerBuilder.instance.appName {
            if self.externalConfigUrl.isEmpty || !self.externalConfigUrl.contains(appName) {
                self.externalConfigUrl = ExternalConfigConstants.configJsonURL.replacingOccurrences(
                    of: ExternalConfigConstants.appNamePlaceholder,
                    with: appName)
            }
            return self.externalConfigUrl
        } else {
            throw ConfigurationParsingError.undefinedAppName
        }
    }
}
