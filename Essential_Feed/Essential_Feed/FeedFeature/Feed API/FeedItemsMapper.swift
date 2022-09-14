import Foundation

internal final class FeedItemsMapper { //internal pra nao ser acessivel de outros modulos
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map{ $0.item }
        }
    }
    
    //representação dos dados da API, pra não quebrar caso o back-end mude algum parametro
    //decouple
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageUrl: image
            )
        }
    }
    
    private static var OK_200StatusCode: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200StatusCode,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  return .failure(RemoteFeedLoader.Error.invalidData)
              }
        return(.success(root.feed))
    }
}
