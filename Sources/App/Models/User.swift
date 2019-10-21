import Authentication
import FluentSQLite
import Vapor


struct UserForClient: Content {
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
    
    init(user: User){
        self.id            = user.id
        self.avatarURL     = user.avatarURL
        self.name          = user.name
        self.surname       = user.surname
        self.birthday      = user.birthday
        self.balance       = user.balance
        self.points        = user.points
        self.email         = user.email
        self.registerDate  = user.registerDate
        self.role          = user.role
        self.orgInfo       = user.orgInfo
    }
    
}

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
    
    /// sudo Change user
    func sudoChange(with clientUser: UserForClient) -> User {
        
        self.balance        = clientUser.balance
        self.points         = clientUser.points
        
        self.email          = clientUser.email
        self.registerDate   = clientUser.registerDate
        self.role           = clientUser.role
        self.orgInfo        = clientUser.orgInfo
        
        return self.change(with: clientUser)
    }
    
    /// Change user
    func change(with clientUser: UserForClient) -> User {
        
        self.avatarURL  = clientUser.avatarURL
        self.name       = clientUser.name
        self.surname    = clientUser.surname
        self.birthday   = clientUser.birthday
        
        return self
    }
    
    func forClient() -> UserForClient {
        return UserForClient(user: self)
    }
}

/// Allows users to be verified by basic / password auth middleware.
extension User: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(User.self, on: conn) { builder in
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
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
