import Essential_Feed
import Foundation

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}


//separate into 2 protocols to respect interface segregation

final class FeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "title for the feed view")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: .init(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: .init(feed: feed))
        loadingView.display(viewModel: .init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: .init(isLoading: false))
    }
}
