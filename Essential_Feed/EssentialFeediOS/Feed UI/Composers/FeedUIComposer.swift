import UIKit
import Essential_Feed

public final class FeedUIComposer {
    private init() {}
    
    public  static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let decorator = MainQueueDispachDecorator(decoratee: feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: decorator)
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let feedPresenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, loader: imageLoader), loadingView: WeakRefVirtualProxy(object: feedController))
        presentationAdapter.presenter = feedPresenter
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}


