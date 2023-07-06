import Essential_Feed
import XCTest

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(errorView: FeedErrorView, loadingView: FeedLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        errorView.display(viewModel: .noError)
        loadingView.display(viewModel: .init(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: .init(feed: feed))
        loadingView.display(viewModel: .init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: .error(message: feedLoadError))
        loadingView.display(viewModel: .init(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_ , view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expect no view messages")
    }
    
    func test_didStartLoadingFeed_displaysErrorMessage() {
        let (sut , view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut , view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysErrorMessageAndStopsLoading() {
        let (sut , view) = makeSUT()
        let error = anyNSError()
        
        sut.didFinishLoadingFeed(with: error)
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: "FEED_VIEW_CONNECTION_ERROR"),
            .display(isLoading: false)
        ])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {

        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private (set) var messages = Set<Message>()
        
        func display(viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}

//Arrays are ordered, when the order doesn't matter, try to use SET, cause if you change the order of methods called, the test will break because we are using an array.
//On this case, SET are better
