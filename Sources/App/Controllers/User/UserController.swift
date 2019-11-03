import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<LoginResponce> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(Private.User.self)
        
        // create new token for this user
        let token = try Private.UserToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req).map { (token) -> (LoginResponce) in
            return LoginResponce(user: user.forClient(), token: token)
        }
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<UserResponse> {
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { request -> Future<Private.User> in
            
            guard request.password == request.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            let hash = try BCrypt.hash(request.password)
            
            return Private.User(email: request.email, orgInfo: request.orgInfo, passwordHash: hash).save(on: req)
        }.map { user in
            // map to public user response (omits password hash)
            return try UserResponse(id: user.requireID(), email: user.email)
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
                    return user.forClient()
                })
        }
    }
    
}

// MARK: Content

struct LoginResponce: Content {
    var user: Public.User
    var token: Private.UserToken
}

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's email address.
    var email: String
    
    var orgInfo: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct UserResponse: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's email address.
    var email: String
}
