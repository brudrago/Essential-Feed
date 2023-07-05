import Essential_Feed
import UIKit

//Generic Decorator
final class MainQueueDispachDecorator<T> {

    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispachDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

//Adding behavior without change code, adding behavior to an instance keeping same interface
//final class MainQueueDispachDecorator: FeedLoader {
//
//    private let decoratee: FeedLoader
//
//    init(decoratee: FeedLoader) {
//        self.decoratee = decoratee
//    }
//
//    func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        decoratee.load { result in
//            if Thread.isMainThread {
//                completion(result)
//            } else {
//                DispatchQueue.main.async {
//                    completion(result)
//                }
//            }
//        }
//    }
//}
