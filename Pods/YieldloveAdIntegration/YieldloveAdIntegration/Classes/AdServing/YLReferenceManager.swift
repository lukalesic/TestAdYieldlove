protocol ReferenceManager {
    func add(referenceHolder: ReferenceHolder)
    func has(referenceHolder: ReferenceHolder) -> Bool
    func deallocateAbandonedRefs()
}

class YLReferenceManager: ReferenceManager {

    private var referenceHolders: [Int: ReferenceHolder] = [:]
    
    func add(referenceHolder: ReferenceHolder) {
        referenceHolders[referenceHolder.id] = referenceHolder
    }
    
    func has(referenceHolder: ReferenceHolder) -> Bool {
        return referenceHolders[referenceHolder.id] != nil
    }
    
    func deallocateAbandonedRefs() {
        for iterator in referenceHolders {
            if let referenceHolder = referenceHolders[iterator.key], referenceHolder.areReferencesReleased {
                referenceHolders[iterator.key] = nil
            }
        }
    }
    
}
