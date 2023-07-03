import UIKit
import Essential_Feed

public final class FeedUIComposer {
    private init() {}
    
    public  static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedImageToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    //[FeedImage] -> Adapt -> [FeedImageCellController]
    
    private static func adaptFeedImageToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(imageLoader: loader, model: model)
            }
        }
    }
}
