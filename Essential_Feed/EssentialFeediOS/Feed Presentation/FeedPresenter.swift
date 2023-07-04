import Essential_Feed

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
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
   
    
    func loadFeed() {
        loadingView?.display(viewModel: .init(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: .init(feed: feed))
            }
            self?.loadingView?.display(viewModel: .init(isLoading: false))
        }
    }
}
