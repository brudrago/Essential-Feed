import Essential_Feed
import XCTest

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: testServerURL)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        
        switch receivedResult {
            
        case let .success(items):
            XCTAssertEqual(items.count,8, "Expected 8 items in the test account feed")
        case let .failure(error):
            XCTFail("Expected sucessful feed result, got \(error) instead.")
        default:
            XCTFail("Expected sucessful feed result, got no result instead.")
        }
    }

}
