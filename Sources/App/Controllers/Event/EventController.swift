//
//  EventController.swift
//  
//
//  Created by Вова Петров on 20.10.2019.
//

import Vapor
import FluentSQLite

final class EventController {
    
    func create(_ req: Request) throws -> Future<Public.Event> {
        return try req.content.decode(Requests.Event.Create.self).flatMap{ createEvent in
            let user = try req.requireAuthenticated(Private.User.self)
            
            return req.transaction(on: .sqlite) { conn in
                return createEvent.toPrivate(personId: user.id!).save(on: conn).flatMap { event in
                    
                    _ = createEvent.periodArray.map { $0.toPrivate(eventId: event.id!).save(on: conn) }
                    _ = createEvent.note.toPrivate(personId: user.id!, eventId: event.id!).save(on: conn)
                    
                    return try event.toPublicFuture(conn: conn)
                }
            }
        }
    }
    
    func change(_ req: Request) throws -> Future<Public.Event> {
        return try req.content.decode(Requests.Event.Change.self).flatMap { params in
            return Private.Event.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { $0.change(params).save(on: req).flatMap { event in
                    
                    _ = try event.periodArray.query(on: req).all().map { periods in
                        _ = periods.map { $0.delete(on: req) }
                        _ = params.periodArray.map { $0.toPrivate(eventId: event.id!).save(on: req) }
                    }
                    
                    return try event.toPublicFuture(conn: req)
                }
            }
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.Event> {
        return try req.content.decode(Requests.Event.Index.self).flatMap { params in
            return Private.Event.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { try $0.toPublicFuture(conn: req) }
        }
    }
    
    func list(_ req: Request) throws -> Future<[Public.Event]> {
        return Private.Event.query(on: req).all().flatMap { privateEvent in
            return try privateEvent.map { try $0.toPublicFuture(conn: req) }.flatten(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.Event.Delete.self).flatMap { params in
            return Private.Event.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
                .delete(on: req)
        }.transform(to: .ok)
    }
}

extension Requests {
    class Event {
        struct Create: Content {
            var title: String
            var periodArray: [Period]
            var maxPersons: Int?
            var categoryId: Int
            var points: Int
            var note: Note
        //    var photos: Private.Photo
            
            func toPrivate(personId: Int) -> Private.Event {
                return Private.Event(title: title, maxPersons: maxPersons, categoryId: categoryId, ownerId: personId)
            }
        }
        
        struct Change: Content {
            var id: Int
            var title: String
            var points: Int
            var maxPersons: Int? //max people
            var periodArray: [Period]
            
            var categoryId: Int
            var ownerId: Int
        }


        struct Delete: Content {
            var id: Int
        }

        struct Index: Content {
            var id: Int
        }
    }
}


struct Period: Content {
    var startDate: Date
    var endDate: Date
    
    func toPrivate(eventId: Int) -> Private.Period {
        return Private.Period(eventId: eventId, startDate: startDate, endDate: endDate)
    }
}

struct Note: Content {
    var theme: String?
    var text: String
    var isAnonimus: Bool
    
    var attachmentId: Int?
    
    func toPrivate(personId: Int, eventId: Int) -> Private.Note {
        return Private.Note(id: nil,
                            eventId: eventId,
                            number: 0,
                            theme: theme,
                            text: text,
                            time: Date(),
                            personId: personId,
                            isAnonimus: isAnonimus,
                            attachmentId: nil)
    }
}
