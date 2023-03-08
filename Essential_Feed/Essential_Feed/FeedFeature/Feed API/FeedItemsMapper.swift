import Foundation

//representação dos dados da API, pra não quebrar caso o back-end mude algum parametro
//decouple

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class FeedItemsMapper { //internal pra nao ser acessivel de outros modulos
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200StatusCode: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200StatusCode,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
