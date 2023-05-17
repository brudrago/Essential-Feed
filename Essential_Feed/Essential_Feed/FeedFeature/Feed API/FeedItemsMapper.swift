import Foundation

//representação dos dados da API, pra não quebrar caso o back-end mude algum parametro
//decouple

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

final class FeedItemsMapper { //internal pra nao ser acessivel de outros modulos
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200StatusCode: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200StatusCode,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
