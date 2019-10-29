//
//  EventController.swift
//  
//
//  Created by Вова Петров on 20.10.2019.
//

import Vapor
import FluentSQLite

final class EventController {
    
    func create(_ req: Request) throws -> Future<Private.Event> {
        return try req.content.decode(CreateEventRequest.self).flatMap({ (createEvent) -> EventLoopFuture<Private.Event> in

            let user = try req.requireAuthenticated(Private.User.self)
            
            return req.transaction(on: .sqlite) { conn -> EventLoopFuture<Private.Event> in
                return createEvent.periodArray.map { $0.toPrivate().save(on: conn) }
                    .flatten(on: conn)
                    .flatMap { periods in
                        return createEvent.comment.toPrivate(personId: user.id!).save(on: conn).flatMap { note in
                            let periodIdArray = periods.map { $0.id! }
                            return createEvent.toPrivate(personId: user.id!, periodIdArray: periodIdArray, noteId: note.id!).save(on: conn)
                    }
                }
            }
        })
    }

    func list(_ req: Request) throws -> Future<[Private.Event]> {
        return Private.Event.query(on: req).all()
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Private.Event.self).flatMap({ $0.delete(on: req) }).transform(to: .ok)
    }
}

struct CreateEventRequest: Content {
    var title: String
    var periodArray: [Period]
    var maxPersons: Int?
    var categoryId: Int
    var points: Int
    var comment: Note
//    var photos: Private.Photo
    
    func toPrivate(personId: Int, periodIdArray: [Int], noteId: Int) -> Private.Event {
        return Private.Event(title: title, periodIdArray: periodIdArray, maxPersons: maxPersons, categoryId: categoryId, ownerId: personId, noteIdArray: [noteId])
    }
    
    struct Period: Content {
        var startDate: Date
        var endDate: Date
        
        func toPrivate() -> Private.Period {
            return Private.Period(startDate: startDate, endDate: endDate)
        }
    }
    
    struct Note: Content {
        var theme: String?
        var text: String
        var isAnonimus: Bool
        
        var attachmentId: Int?
        
        func toPrivate(personId: Int) -> Private.Note {
            return Private.Note(id: nil,
                                number: 0,
                                theme: theme,
                                text: text,
                                time: Date(),
                                personId: personId,
                                isAnonimus: isAnonimus,
                                attachmentId: nil)
        }
    }
}
