import Essential_Feed
import UIKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private var imageLoader: FeedImageDataLoader
    private var model: FeedImage
    
    init(imageLoader: FeedImageDataLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    var description: String? {
        return model.description
    }
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
