//
//  File.swift
//  
//
//  Created by Вова Петров on 03.11.2019.
//

import Vapor
import FluentSQLite

final class NoteController {
    
    func create(_ req: Request) throws -> Future<Public.Note> {
        return try req.content.decode(CreateNoteRequest.self).flatMap{ params in
            let user = try req.requireAuthenticated(Private.User.self)
            
            return Private.Event.find(params.eventId, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
            .flatMap { event in
                return try event.noteArray.query(on: req).count().flatMap { count in
                    return Private.Note(id: nil,
                                        eventId: params.eventId,
                                        number: count,
                                        theme: params.theme,
                                        text: params.text,
                                        time: Date(),
                                        personId: user.id!,
                                        isAnonimus: params.isAnonimus,
                                        attachmentId: nil)
                        .save(on: req)
                        .map { note in
                            return note.toPublic()
                    }
                }
            }
        }
    }
    
    func change(_ req: Request) throws -> Future<Public.Note> {
        return try req.content.decode(ChangeNoteRequest.self).flatMap { params in
            return Private.Note.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { $0.change(params).save(on: req).map { note in
                    return note.toPublic()
                }
            }
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.Note> {
        return try req.content.decode(IndexNoteRequest.self).flatMap { params in
            return Private.Note.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
    }
    
    func list(_ req: Request) throws -> Future<[Public.Note]> {
        return try req.content.decode(ListNoteFiltered.self).flatMap { params in
            var query = Private.Note.query(on: req)
            if let userId = params.userId {
                query = query.filter(\.personId, .equal, userId)
            }
            if let eventId = params.eventId {
                query = query.filter(\.eventId, .equal, eventId)
            }
            
            return query.all().map { notes in
                notes.map{ $0.toPublic() }
            }
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(DeleteNoteRequest.self).flatMap { params in
            return Private.Note.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
                .delete(on: req)
        }.transform(to: .ok)
    }
}

struct ListNoteFiltered: Content {
    var eventId: Int?
    var userId: Int?
}

struct CreateNoteRequest: Content {
    var eventId: Int
    var theme: String?
    var text: String
    var isAnonimus: Bool
}

struct ChangeNoteRequest: Content {
    var id: Int
    var theme: String?
    var text: String
    var isAnonimus: Bool
}


struct DeleteNoteRequest: Content {
    var id: Int
}

struct IndexNoteRequest: Content {
    var id: Int
}
