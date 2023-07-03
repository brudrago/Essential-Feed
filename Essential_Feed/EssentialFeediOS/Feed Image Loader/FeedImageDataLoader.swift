import Foundation


//Adding FeedImageDataLoader protocol abstraction, we decouple the ViewController from concrete implementations like URlSession
//ViewController doesn`t care where the image data comes from (e.g, cache or network), this way we are free to change the implementation or add more funcionalities on demand without having to modify the controller (open/close principle)

//This protocol give to client the responsability of manage the state
public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
