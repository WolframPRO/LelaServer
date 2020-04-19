//
//  File.swift
//
//
//  Created by Вова Петров on 23.01.2020.
//

import FluentSQLite
import Vapor

extension Public {
    struct AwardType: Content {
        var id: Int

        var title: String
        var description: String
        var isAvailable: Bool
        var price: Double

        var imageUrl: String?
    }
}

extension Private {
    final class AwardType: SQLiteModel {
        var id: Int?

        var title: String
        var description: String
        var isAvailable: Bool
        var price: Double

        var imageUrl: String?

        func toPublic() -> Public.AwardType {
            return Public.AwardType(id: id ?? -1, title: title, description: description, isAvailable: isAvailable, price: price, imageUrl: imageUrl)
        }
    }
}

/// Allows `AwardType` to be used as a Fluent migration.
extension Private.AwardType: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.AwardType.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.description)
            builder.field(for: \.isAvailable)
            builder.field(for: \.price)

            builder.field(for: \.imageUrl)

            builder.unique(on: \.title)
        }
    }
}

extension Private.AwardType: Content { }
extension Private.AwardType: Parameter { }
