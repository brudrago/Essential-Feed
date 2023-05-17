import Foundation

public typealias RetrieveCachedFeedResult = Result<CachedFeed, Error>

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsetionCompletion = (Error?) -> Void
    typealias RetrievalResult = Result<CachedFeed, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsetionCompletion)
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
