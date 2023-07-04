import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {

    @IBOutlet private var view: UIRefreshControl?
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
        
    }

    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }
}

//FeedRefreshViewController only holds reference to presenter to call loadFeed method
//One way to decouple is to pass a closure loadFeed: () -> Void and another is to use delegate
