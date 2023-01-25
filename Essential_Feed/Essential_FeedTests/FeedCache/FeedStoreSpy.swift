import Essential_Feed
import Foundation

final class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
    }
    private (set) var receivedMessages = [ReceivedMessages]()
    //garante quais msgs estao sendo chamadas,quais valores e qual a ordem
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsetionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccesfuly(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsetionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
}
