//
//  Category.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

extension Public {
    struct Category: Content {
        var id: Int
        
        var title: String
        var iconId: String?
    }
}

extension Private {
    final class Category: SQLiteModel {
        
        var id: Int?
        
        var title: String
        var iconId: String?
        
        var eventArray: Children<Category, Event> {
            return children(\.categoryId)
        }

        init(id: Int? = nil, title: String, iconId: String? = nil) {
            self.id = id
            self.title = title
            self.iconId = iconId
        }
        
        func toPublic() -> Public.Category {
            return Public.Category(id: id!, title: title, iconId: iconId)
        }
    }
}
/// Allows `Category` to be used as a Fluent migration.
extension Private.Category: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.Category.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.iconId)
            
            builder.unique(on: \.title)
        }
    }
}

extension Private.Category: Content { }
extension Private.Category: Parameter { }
