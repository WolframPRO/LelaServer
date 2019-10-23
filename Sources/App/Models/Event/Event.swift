//
//  Event.swift
//  Lela
//
//  Created by варя on 21/05/2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

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
        
        var partsId: [Int]
        var parts: Children<Event, Part> {
            return children(\.id)
        }
        
        var notesId: [Int]
        var notes: Children<Event, Note> {
            return children(\.id)
        }
        
        var photosId: [Int]
        var photos: Children<Event, Photo> {
            return children(\.id)
        }
        
        init(id: Int? = nil, title: String, points: Int = 0, periodIdArray: [Int], maxPersons: Int?, categoryId: Int, ownerId: Int, partsId: [Int] = [], notesId: [Int] = [], photosId: [Int] = []) {
            self.id = id
            self.title = title
            self.points = points
            self.periodIdArray = periodIdArray
            self.maxPersons = maxPersons
            self.categoryId = categoryId
            self.ownerId = ownerId
            self.partsId = partsId
            self.notesId = notesId
            self.photosId = photosId
        }
    }
}

extension Private.Event: Migration { }
extension Private.Event: Content { }
extension Private.Event: Parameter { }
