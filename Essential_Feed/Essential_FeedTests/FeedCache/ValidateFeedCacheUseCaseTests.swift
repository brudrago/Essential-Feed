import Essential_Feed
import XCTest

//Esse use case vai ser criado pra separar a lógica de validar/deletar da lógica de Load Cache
//Principio de Separating Queries & Side Effetcs

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOld() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()

            expect(sut, toCompleteWith: .failure(deletionError), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletion(with: deletionError)
            })
        }

        func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
            let (sut, store) = makeSUT()

            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletionSuccessfuly()
            })
        }

        func test_validateCache_succeedsOnEmptyCache() {
            let (sut, store) = makeSUT()

            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrievalWithEmptyCache()
            })
        }

        func test_validateCache_succeedsOnNonExpiredCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
            })
        }

        func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            let deletionError = anyNSError()

            expect(sut, toCompleteWith: .failure(deletionError), when: {
                store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
                store.completeDeletion(with: deletionError)
            })
        }

        func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
                store.completeDeletionSuccessfuly()
            })
        }
    
    func test_validateCache_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache { _ in }
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
