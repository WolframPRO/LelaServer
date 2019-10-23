//
//  Part.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

extension Private {
    final class Part: SQLiteModel {
        
        var id: Int?
        var confirmed: Bool = false
        
        var userId: Int
        var user: Children<Part, User> {
            return children(\.id)
        }
        
        var eventId: Int
        var event: Parent<Part, Event> {
            return parent(\.eventId)
        }
        
        
        init(id: Int?, userId: Int, eventId: Int) {
            self.id = id
            self.userId = userId
            self.eventId = eventId
        }
    }
}

extension Private.Part: Migration { }
extension Private.Part: Content { }
extension Private.Part: Parameter { }
