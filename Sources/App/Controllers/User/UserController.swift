import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<Response.User.Login> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(Private.User.self)
        
        // create new token for this user
        let token = try Private.UserToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req).map { token in
            return Response.User.Login(user: user.toPublic(), token: token)
        }
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<Response.User.User> {
        // decode request content
        return try req.content.decode(Requests.User.Create.self).flatMap { request -> Future<Private.User> in
            
            guard request.password == request.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            let hash = try BCrypt.hash(request.password)
            
            return Private.User(email: request.email, orgInfo: request.orgInfo, passwordHash: hash).save(on: req)
        }.map { user in
            // map to public user response (omits password hash)
            return try Response.User.User(id: user.requireID(), email: user.email)
        }
    }
}

extension UserController {
    
    func change(_ req: Request) throws -> Future<Public.User> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(Private.User.self)
        
        // decode request content
        return try req.content.decode(Public.User.self).flatMap { userForClient in
            // save new todo
            return user.change(with: userForClient)
                .save(on: req).map({ (user) -> (Public.User) in
                    return user.toPublic()
                })
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.User> {
        return try req.content.decode(Requests.User.Index.self).flatMap { params in
            return Private.User.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
    }
    
    func list(_ req: Request) throws -> Future<[Public.User]> {
        return Private.User.query(on: req).all().map { $0.map { $0.toPublic() } }
    }
}

// MARK: Content

extension Requests {
    class User {
        
        struct Index: Content {
            var id: Int
        }
        
        /// Data required to create a user.
        struct Create: Content {
            /// User's email address.
            var email: String
            
            var orgInfo: String
            
            /// User's desired password.
            var password: String
            
            /// User's password repeated to ensure they typed it correctly.
            var verifyPassword: String
        }
    }
}

extension Response {
    class User {
        struct Login: Content {
            var user: Public.User
            var token: Private.UserToken
        }

        /// Public representation of user data.
        struct User: Content {
            /// User's unique identifier.
            /// Not optional since we only return users that exist in the DB.
            var id: Int
            
            /// User's email address.
            var email: String
        }
    }
}
