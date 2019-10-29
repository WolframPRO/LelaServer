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
        
        var periodIdArray: [Int]
        var periodArray: Children<Event, Period> {
            return children(\.id)
        }
        
        var categoryId: Int
        var category: Parent<Event, Category> {
            return parent(\.categoryId)
        }
        
        var ownerId: Int
        var owner: Parent<Event, User> {
            return parent(\.ownerId)
        }
        
        var partIdArray: [Int]
        var partArray: Children<Event, Part> {
            return children(\.id)
        }
        
        var noteIdArray: [Int]
        var noteArray: Children<Event, Note> {
            return children(\.id)
        }
        
        var photoIdArray: [Int]
        var photoArray: Children<Event, Photo> {
            return children(\.id)
        }
        
        init(id: Int? = nil, title: String, points: Int = 0, periodIdArray: [Int], maxPersons: Int?, categoryId: Int, ownerId: Int, partIdArray: [Int] = [], noteIdArray: [Int] = [], photoIdArray: [Int] = []) {
            self.id = id
            self.title = title
            self.points = points
            self.periodIdArray = periodIdArray
            self.maxPersons = maxPersons
            self.categoryId = categoryId
            self.ownerId = ownerId
            self.partIdArray = partIdArray
            self.noteIdArray = noteIdArray
            self.photoIdArray = photoIdArray
        }
        
        func toPublicFuture(conn: DatabaseConnectable) throws -> EventLoopFuture<Public.Event> {
            return try periodArray.query(on: conn).all().flatMap {[unowned self] periods in
                let periods = periods.map { $0.toPublic() }
                return try self.partArray.query(on: conn).all().flatMap {[unowned self] parts in
                    let parts = parts.map { $0.toPublic() }
                    return try self.noteArray.query(on: conn).all().flatMap {[unowned self] notes in
                        let notes = notes.map { $0.toPublic() }
                        return try self.photoArray.query(on: conn).all().flatMap { photos in
                            let photos = photos.map { $0.toPublic() }
                            return Public.Event(id: id!, title: title, points: points, maxPersons: maxPersons, periodArray: periods, categoryId: categoryId, ownerId: ownerId, partArray: parts, noteArray: notes, photoArray: photos)
                        }
                    }
                }
            }
            
        }
    }
}

extension Private.Event: Migration { }
extension Private.Event: Content { }
extension Private.Event: Parameter { }
