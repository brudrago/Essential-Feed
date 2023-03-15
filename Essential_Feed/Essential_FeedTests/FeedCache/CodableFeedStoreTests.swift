import Essential_Feed
import XCTest

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmpyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrieval")
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrieveFeed, retrieveTimestamp):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimestamp, timestamp)
                default:
                    XCTFail("Expected to found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}

//-MARK: - Helpers

extension CodableFeedStoreTests {
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let url = testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
