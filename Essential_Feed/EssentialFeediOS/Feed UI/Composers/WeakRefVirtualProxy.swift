import Essential_Feed
import UIKit

//In this part we bring memory management to the Compose layer, instead of let on Presenter
//WeakRefVirtualProxy will hold an weak reference of the object instance and pass the message forward
//when we set loading view, we weakfy with VirtualProxy

 final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(viewModel: FeedErrorViewModel) {
        object?.display(viewModel: viewModel)
    }
}
