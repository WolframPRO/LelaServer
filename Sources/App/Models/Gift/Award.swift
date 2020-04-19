//
//  Award.swift
//
//
//  Created by Вова Петров on 23.01.2020.
//

import FluentSQLite
import Vapor

extension Public {
    struct Award: Content {
        var id: Int?
        
        var typeId: Int
        var ownerId: Int?
        var operatorId: Int?
        
        ///0 - Free
        ///1 - Waiting
        ///2 - Awarded
        ///3 - Conflicted
        ///4 - Cancelled
        var status: Int
        
        var priceFact: Double
        var description: String
    }
}

extension Private {
    final class Award: SQLiteModel {
        var id: Int?
        
        var typeId: Int
        var ownerId: Int?
        var operatorId: Int?
        
        ///0 - Free
        ///1 - Waiting
        ///2 - Awarded
        ///3 - Conflicted
        ///4 - Cancelled
        var status: Int
        
        var priceFact: Double
        var description: String
        
        func toPublic() -> Public.Award {
            return Public.Award(id: id, typeId: typeId, ownerId: ownerId, operatorId: operatorId, status: status, priceFact: priceFact, description: description)
        }
    }
}

/// Allows `Award` to be used as a Fluent migration.
extension Private.Award: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.Award.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            
            builder.field(for: \.typeId)
            builder.field(for: \.ownerId)
            builder.field(for: \.operatorId)
            
            builder.field(for: \.status)
            
            builder.field(for: \.priceFact)
            builder.field(for: \.description)
            
            builder.reference(from: \.typeId, to: \Private.AwardType.id,
                              onUpdate: ._noAction, onDelete: ._cascade)
            builder.reference(from: \.ownerId, to: \Private.User.id,
                              onUpdate: ._noAction, onDelete: ._noAction)
            builder.reference(from: \.operatorId, to: \Private.User.id,
                              onUpdate: ._noAction, onDelete: ._noAction)
        }
    }
}

extension Private.Award: Content { }
extension Private.Award: Parameter { }
