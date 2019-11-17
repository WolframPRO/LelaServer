import Authentication
import FluentSQLite
import Vapor

extension Public {
    struct User: Content {
        var id: Int
        
        /// User's full name.
        var avatarURL: String?
        var name: String?
        var surname: String?
        var birthday: String?
        
        var balance: Int
        var points: Int
        
        /// User's email address.
        var email: String
        var registerDate: Date
        var role: Int
        var orgInfo: String
        
    }
}

extension Private {
    /// A registered user, capable of owning todo items.
    final class User: SQLiteModel {
        var id: Int?
        
        /// User's full name.
        var avatarURL: String?
        var name: String?
        var surname: String?
        var birthday: String?
        
        var balance: Int
        var points: Int
        
        /// User's email address.
        var email: String
        var registerDate: Date
        var role: Int
        var orgInfo: String
        
        /// BCrypt hash of the user's password.
        var passwordHash: String
        
        /// Creates a new `User`.
        init(id: Int? = nil,
             avatarURL: String? = nil,
             name: String? = nil,
             surname: String? = nil,
             birthday: String? = nil,
             balance: Int = 0,
             points: Int = 0,
             email: String,
             registerDate: Date = Date(),
             role: Int = 0,
             orgInfo: String,
             passwordHash: String) {
            
            self.id = id
            
            self.avatarURL = avatarURL
            self.name = name
            self.surname = surname
            self.birthday = birthday
            
            self.balance = balance
            self.points = points
            
            self.email = email
            self.registerDate = registerDate
            self.role = role
            self.orgInfo = orgInfo
            
            self.passwordHash = passwordHash
        }
        
        func toPublic() -> Public.User {
            return Public.User(id: id!,
                               avatarURL: avatarURL,
                               name: name,
                               surname: surname,
                               birthday: birthday,
                               balance: balance,
                               points: points,
                               email: email,
                               registerDate: registerDate,
                               role: role,
                               orgInfo: orgInfo)
        }
        
        /// sudo Change user
        func sudoChange(with clientUser: Public.User) -> User {
            
            self.balance        = clientUser.balance
            self.points         = clientUser.points
            
            self.email          = clientUser.email
            self.registerDate   = clientUser.registerDate
            self.role           = clientUser.role
            self.orgInfo        = clientUser.orgInfo
            
            return self.change(with: clientUser)
        }
        
        /// Change user
        func change(with clientUser: Public.User) -> User {
            
            self.avatarURL  = clientUser.avatarURL
            self.name       = clientUser.name
            self.surname    = clientUser.surname
            self.birthday   = clientUser.birthday
            
            return self
        }
    }
}

/// Allows users to be verified by basic / password auth middleware.
extension Private.User: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<Private.User, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<Private.User, String> {
        return \.passwordHash
    }
}

/// Allows users to be verified by bearer / token auth middleware.
extension Private.User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = Private.UserToken
}

/// Allows `User` to be used as a Fluent migration.
extension Private.User: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            
            builder.field(for: \.avatarURL)
            builder.field(for: \.name)
            builder.field(for: \.surname)
            builder.field(for: \.birthday)
            
            builder.field(for: \.balance)
            builder.field(for: \.points)
            
            builder.field(for: \.email)
            builder.field(for: \.registerDate)
            builder.field(for: \.role)
            builder.field(for: \.orgInfo)
            
            builder.field(for: \.passwordHash)
            
            builder.unique(on: \.email)
        }
    }
}

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension Private.User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension Private.User: Parameter { }
