import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsetionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsetionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
