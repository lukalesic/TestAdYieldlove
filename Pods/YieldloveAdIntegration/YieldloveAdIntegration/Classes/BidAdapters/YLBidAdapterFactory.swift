protocol BidAdapterFactory {
    func makeBidAdapters(bidTuple: BidTuple) -> [BidAdapter]
}

class YLBidAdapterFactory: BidAdapterFactory {
    
    let prebidAdUnitFactory: PrebidAdUnitFactory?
    
    init(prebidAdUnitFactory: PrebidAdUnitFactory?) {
        self.prebidAdUnitFactory = prebidAdUnitFactory
    }
    
    func makeBidAdapters(bidTuple: BidTuple) -> [BidAdapter] {
        let (originalRequest, adUnitData) = bidTuple
        var adapters: [BidAdapter] = []
        if let criteoPublisherId = adUnitData.criteoPublisherId {
            let criteoBidAdapter = YLCriteoBidAdapter(publisherId: criteoPublisherId)
            adapters.append(criteoBidAdapter)
        }
        if let accountId = adUnitData.accountId, let prebidAdUnitFactory = self.prebidAdUnitFactory {
            var prebidFactory = prebidAdUnitFactory
            prebidFactory.accountId = accountId
            let prebidAdapter = YLPrebidBidAdapter(requestData: originalRequest, adUnitFactory: prebidFactory)
            adapters.append(prebidAdapter)
        }
        return adapters
    }
}
