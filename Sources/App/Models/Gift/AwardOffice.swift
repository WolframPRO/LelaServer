//
//  AwardOffice.swift
//
//
//  Created by Вова Петров on 23.01.2020.
//
//
import FluentSQLite
import Vapor

extension Public {
    struct AwardOffice: Content {
        var id: Int

        var address: String
        var operatorFio: String
        var timetable: String
    }
}

extension Private {
    final class AwardOffice: SQLiteModel {
        var id: Int?

        var address: String
        var operatorFio: String
        var timetable: String

        func toPublic() -> Public.AwardOffice {
            return Public.AwardOffice(id: id ?? -1, address: address, operatorFio: operatorFio, timetable: timetable)
        }
        
        func change(_ changeRequest: Requests.AwardOffice.Change) -> AwardOffice {
            self.address = changeRequest.address
            self.operatorFio = changeRequest.operatorFio
            self.timetable = changeRequest.timetable
            
            return self
        }
    }
}

/// Allows `AwardOffice` to be used as a Fluent migration.
extension Private.AwardOffice: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.AwardOffice.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.address)
            builder.field(for: \.operatorFio)
            builder.field(for: \.timetable)
        }
    }
}

extension Private.AwardOffice: Content { }
extension Private.AwardOffice: Parameter { }
