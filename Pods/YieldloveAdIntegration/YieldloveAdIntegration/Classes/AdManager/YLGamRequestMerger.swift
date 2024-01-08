import GoogleMobileAds

class YLGamRequestMerger {
    
    public static func merge(_ highPrioRequest: GAMRequest?, _ lowPrioRequest: GAMRequest?) -> GAMRequest {
        if let req1 = highPrioRequest, let req2 = lowPrioRequest {
            return mergeIntoNewRequest(req1, req2)
        } else if let req = highPrioRequest {
            return mergeIntoNewRequest(req)
        } else if let req = lowPrioRequest {
            return mergeIntoNewRequest(req)
        }
        return GAMRequest()
    }
    
    private static func mergeIntoNewRequest(_ req: GAMRequest) -> GAMRequest {
        let gamRequest = GAMRequest()
        gamRequest.publisherProvidedID = req.publisherProvidedID
        gamRequest.contentURL = req.contentURL
        gamRequest.requestAgent = req.requestAgent
        mergeCustomTargeting(gamRequest, nil, req)
        mergeCategoryExclusions(gamRequest, nil, req)
        mergeKeywords(gamRequest, nil, req)
        return gamRequest
    }
    
    private static func mergeIntoNewRequest(_ req1: GAMRequest, _ req2: GAMRequest) -> GAMRequest {
        let gamRequest = GAMRequest()
        gamRequest.publisherProvidedID = req1.publisherProvidedID ?? req2.publisherProvidedID
        gamRequest.contentURL = req1.contentURL ?? req2.contentURL
        gamRequest.requestAgent = req1.requestAgent ?? req2.requestAgent
        mergeCustomTargeting(gamRequest, req2, req1)
        mergeCategoryExclusions(gamRequest, req2, req1)
        mergeKeywords(gamRequest, req2, req1)
        return gamRequest
    }

    private static func mergeKeywords(_ newRequest: GAMRequest, _ globalRequest: GAMRequest?, _ localRequest: GAMRequest) {
        newRequest.keywords = mergeStringArrays(
                globalRequest?.keywords,
                localRequest.keywords)
    }

    private static func mergeCategoryExclusions(_ newRequest: GAMRequest, _ globalRequest: GAMRequest?, _ localRequest: GAMRequest) {
        newRequest.categoryExclusions = mergeStringArrays(
                globalRequest?.categoryExclusions,
                localRequest.categoryExclusions)
    }
    
    private static func mergeStringArrays(_ globalArray: [String]?, _ localArray: [String]?) -> [String]? {
        return (globalArray ?? []) + (localArray ?? [])
    }

    private static func mergeCustomTargeting(_ newRequest: GAMRequest, _ globalRequest: GAMRequest?, _ localRequest: GAMRequest) {
        newRequest.customTargeting = globalRequest?.customTargeting ?? [:]
        newRequest.customTargeting?.merge(localRequest.customTargeting ?? [:]) { (_, localValue) in
            localValue
        }
    }
    
    public static func mergeInto(request: GAMRequest, keyValues: [String: String]) -> GAMRequest {
        var requestKeyValues = request.customTargeting ?? [:]
        for (key, value) in keyValues {
            requestKeyValues[key] = value
        }
        request.customTargeting = requestKeyValues
        return request
    }
}
