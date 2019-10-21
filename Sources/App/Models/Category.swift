//
//  Category.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import Foundation

import FluentSQLite
import Vapor

class Category {

    final class Model: SQLiteModel {
        
        var id: Int?
        
        var title: String
        var iconId: String?

        init(id: Int? = nil, title: String, iconId: String? = nil) {
            self.id = id
            self.title = title
            self.iconId = iconId
        }
    }

}
/// Allows `Category` to be used as a Fluent migration.
extension Category.Model: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Category.Model.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.iconId)
            
            builder.unique(on: \.title)
        }
    }
}

extension Category.Model: Content { }
extension Category.Model: Parameter { }
