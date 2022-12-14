
import XCTest

class LocalFeedLoader {
    var store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCachedFeddCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_doesNotDeleteCacheUpoCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeddCallCount, 0)
    }
}
