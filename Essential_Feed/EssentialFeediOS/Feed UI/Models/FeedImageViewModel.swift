import Essential_Feed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private var imageLoader: FeedImageDataLoader
    private var model: FeedImage
    private let imageTransformer: (Data) -> Image?
    
    init(imageLoader: FeedImageDataLoader, model: FeedImage, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformer = imageTransformer
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
    
    var onImageLoad: Observer<Image>?
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
        if let image = (try? result.get()).flatMap(imageTransformer) {
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
