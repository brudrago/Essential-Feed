import Essential_Feed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "description", location: "location", url: anyURL())
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let localItems = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (models, localItems)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
