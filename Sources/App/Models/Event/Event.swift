//
//  Event.swift
//  Lela
//
//  Created by варя on 21/05/2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

extension Public {
    struct Event: Content {
        var id: Int
        var title: String
        var points: Int
        var maxPersons: Int? //max people
        
        var periodArray: [Period]
        var categoryId: Int
        var ownerId: Int
        
        var partArray: [Part]
        var noteArray: [Note]
        var photoArray: [Photo]
    }
}

extension Private {
    final class Event: SQLiteModel {
        
        var id: Int?
        var title: String
        var points: Int
        var maxPersons: Int? //max people
        
        var periodArray: Children<Event, Period> {
            return children(\.eventId)
        }
        
        var categoryId: Int
        var category: Parent<Event, Category> {
            return parent(\.categoryId)
        }
        
        var ownerId: Int
        var owner: Parent<Event, User> {
            return parent(\.ownerId)
        }
        
        var partArray: Children<Event, Part> {
            return children(\.eventId)
        }
        
        var noteArray: Children<Event, Note> {
            return children(\.eventId)
        }
        
        var photoArray: Children<Event, Private.Photo> {
            return children(\.eventId)
        }
        
        init(id: Int? = nil, title: String, points: Int = 0, maxPersons: Int?, categoryId: Int, ownerId: Int) {
            self.id = id
            self.title = title
            self.points = points
            self.maxPersons = maxPersons
            self.categoryId = categoryId
            self.ownerId = ownerId
        }
        
        func toPublicFuture(conn: DatabaseConnectable) throws -> Future<Public.Event> {
            return try periodArray.query(on: conn).all().flatMap { periods in
                let periods = periods.map { $0.toPublic() }
                return try self.partArray.query(on: conn).all().flatMap { parts in
                    let parts = parts.map { $0.toPublic() }
                    return try self.noteArray.query(on: conn).all().flatMap { notes in
                        let notes = notes.map { $0.toPublic() }
                        return try self.photoArray.query(on: conn).all().map { photos in
                            let photos = photos.map { $0.toPublic() }
                            return Public.Event(id: self.id!, title: self.title, points: self.points, maxPersons: self.maxPersons, periodArray: periods, categoryId: self.categoryId, ownerId: self.ownerId, partArray: parts, noteArray: notes, photoArray: photos)
                        }
                    }
                }
            }
        }
        
        func change(_ params: Requests.Event.Change) -> Event {
            self.title      = params.title
            self.points     = params.points
            self.maxPersons = params.maxPersons
            
            self.categoryId = params.categoryId
            self.ownerId    = params.ownerId
            
            return self
        }
        
    }
}

extension Private.Event: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Private.Event.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.points)
            builder.field(for: \.maxPersons)
            builder.field(for: \.categoryId)
            builder.field(for: \.ownerId)
            builder.reference(from: \.categoryId,
                              to: \Private.Category.id,
                              onUpdate: ._noAction,
                              onDelete: ._noAction)
            builder.reference(from: \.ownerId,
                              to: \Private.User.id,
                              onUpdate: ._noAction,
                              onDelete: ._noAction)
        }
    }
}
extension Private.Event: Content { }
extension Private.Event: Parameter { }
