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
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        loadingView?.display(viewModel: .init(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(viewModel: .init(feed: feed))
        loadingView?.display(viewModel: .init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(viewModel: .init(isLoading: false))
    }
}
