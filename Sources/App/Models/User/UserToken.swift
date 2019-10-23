import Authentication
import Crypto
import FluentSQLite
import Vapor

extension Private {
    /// An ephermal authentication token that identifies a registered user.
    final class UserToken: SQLiteModel {
        /// Creates a new `UserToken` for a given user.
        static func create(userID: User.ID) throws -> UserToken {
            // generate a random 128-bit, base64-encoded string.
            let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
            // init a new `UserToken` from that string.
            return .init(string: string, userID: userID)
        }
        
        /// See `Model`.
        static var deletedAtKey: TimestampKey? { return \.expiresAt }
        
        /// UserToken's unique identifier.
        var id: Int?
        
        /// Unique token string.
        var string: String
        
        /// Reference to user that owns this token.
        var userID: User.ID
        
        /// Expiration date. Token will no longer be valid after this point.
        var expiresAt: Date?
        
        /// Creates a new `UserToken`.
        init(id: Int? = nil, string: String, userID: User.ID) {
            self.id = id
            self.string = string
            // set token to expire after 5 hours
            self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
            self.userID = userID
        }
    }
}

extension Private.UserToken {
    /// Fluent relation to the user that owns this token.
    var user: Parent<Private.UserToken, Private.User> {
        return parent(\.userID)
    }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension Private.UserToken: Token {
    /// See `Token`.
    typealias UserType = Private.User
    
    /// See `Token`.
    static var tokenKey: WritableKeyPath<Private.UserToken, String> {
        return \.string
    }
    
    /// See `Token`.
    static var userIDKey: WritableKeyPath<Private.UserToken, Private.User.ID> {
        return \.userID
    }
}

/// Allows `UserToken` to be used as a Fluent migration.
extension Private.UserToken: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.UserToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.userID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.userID, to: \Private.User.id)
        }
    }
}

/// Allows `UserToken` to be encoded to and decoded from HTTP messages.
extension Private.UserToken: Content { }

/// Allows `UserToken` to be used as a dynamic parameter in route definitions.
extension Private.UserToken: Parameter { }
