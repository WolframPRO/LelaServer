//
//  File.swift
//  
//
//  Created by Вова Петров on 03.11.2019.
//

import Vapor
import FluentSQLite

final class PartController {
    
    func create(_ req: Request) throws -> Future<Public.Part> {
        return try req.content.decode(CreatePartRequest.self).flatMap{ params in
            return Private.Event.find(params.eventId, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
            .flatMap { event in
                return Private.User.find(params.userId, on: req)
                    .unwrap(or: Abort(HTTPResponseStatus.notFound))
                    .flatMap { user in
                        return Private.Part(id: nil, userId: user.id!, eventId: event.id!)
                            .save(on: req).map { $0.toPublic() }
                }
            }
        }
    }
    
    func confirm(_ req: Request) throws -> Future<Public.Part> {
        return try req.content.decode(ConfirmPartRequest.self).flatMap { params in
            return Private.Part.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { part in
                    part.confirmed = params.confirmed
                    return part.save(on: req).map { $0.toPublic() }
            }
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.Part> {
        return try req.content.decode(IndexEventRequest.self).flatMap { params in
            return Private.Part.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
    }
    
    func list(_ req: Request) throws -> Future<[Public.Part]> {
        return try req.content.decode(ListPartForEvent.self).flatMap { params in
            return Private.Event.find(params.eventId, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
            .flatMap { event in
                try event.partArray.query(on: req).all().map { $0.map { $0.toPublic() } }
            }
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(DeleteEventRequest.self).flatMap { params in
            return Private.Part.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
                .delete(on: req)
        }.transform(to: .ok)
    }
}

struct ListPartForEvent: Content {
    var eventId: Int
}

struct CreatePartRequest: Content {
    var userId: Int
    var eventId: Int
}

struct ConfirmPartRequest: Content {
    var id: Int
    var confirmed: Bool
}


struct DeletePartRequest: Content {
    var id: Int
}

struct IndexPartRequest: Content {
    var id: Int
}

