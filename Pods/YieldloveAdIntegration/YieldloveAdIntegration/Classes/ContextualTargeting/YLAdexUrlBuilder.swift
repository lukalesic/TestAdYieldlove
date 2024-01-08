class YLAdexUrlBuilder {
    
    static func buildTheAdexRequestUrl(data: YLContextualTargetingData) -> String? {
        var baseUrl = ContextualTargetingConstants.theAdexApiUrlTemplate
        baseUrl = replaceIdfaPlaceholder(baseUrl: baseUrl, idfa: data.idfa)
        return addContentUrlKeyValue(baseUrl: baseUrl, contentURL: data.contentURL)
    }
    
    private static func replaceIdfaPlaceholder(baseUrl: String, idfa: String) -> String {
        return baseUrl.replacingOccurrences(of: ContextualTargetingConstants.theAdexApiUrlTemplateIdfaPlaceholder, with: idfa)
    }
    
    private static func addContentUrlKeyValue(baseUrl: String, contentURL: String) -> String? {
        let rawKV = "{\"\(ContextualTargetingConstants.contentURLParameterName)\":\"\(contentURL)\"}"
        if let encodedKV = rawKV.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return baseUrl + "&kv=\(encodedKV)"
        }
        return nil
    }
    
}
