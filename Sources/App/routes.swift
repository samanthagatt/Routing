import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    /*
     router.get("articles", Article.parameter) { req -> String in
         let article = try req.parameters.next(Article.self)
         return "Loading article: \(article.title) - \(article.id)"
     }
     */
    
    router.get("articles", Article.parameter) { req -> Future<Article> in
        let article = try req.parameters.next(Article.self)
        return article.map { article in
            guard let article = article else {
                throw Abort(.badRequest)
            }
            return article
        }
    }
    
    router.group("hello") { group in
        group.get("world") { req in
            return "Hello, world!"
        }
        group.get("kitty") { req in
            return "Hello Kitty!"
        }
    }
    
    try router.grouped("admin").register(collection: AdminCollection())
}

final class AdminCollection: RouteCollection {
    func boot(router: Router) throws {
        let article = router.grouped("article", Int.parameter)
        
        article.get("read") { req -> String in
            let articleID = try req.parameters.next(Int.self)
            return "Reading article \(articleID)"
        }
        
        article.get("edit") { req -> String in
            let articleID = try req.parameters.next(Int.self)
            return "Editing article \(articleID)"
        }
    }
}

struct Article: Parameter, Content {
    var id: Int
    var title: String
    
    init(id: Int, title: String = "Routing Practice") {
        self.id = id
        self.title = title
    }
    
    static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Article?> {
        guard let id = Int(parameter) else {
            throw Abort(.badRequest)
        }
        // return Article(id: parameter)
        return Future.map(on: container) { Article(id: id) }
    }
}
