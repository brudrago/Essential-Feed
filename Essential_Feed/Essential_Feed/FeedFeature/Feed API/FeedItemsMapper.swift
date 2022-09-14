import Foundation

internal final class FeedItemsMapper { //internal pra nao ser acessivel de outros modulos
    private struct Root: Decodable {
        let items: [Item]
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
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200StatusCode else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map{ $0.item }
    }
}
