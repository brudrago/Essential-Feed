import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {

    private (set) lazy var view = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
        
    }

    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

//FeedRefreshViewController only holds reference to presenter to call loadFeed method
//One way to decouple is to pass a closure loadFeed: () -> Void and another is to use delegate
