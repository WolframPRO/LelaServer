//
//  AwardTypeController.swift
//  
//
//  Created by Вова Петров on 19.04.2020.
//

import Vapor
import FluentSQLite

final class AwardTypeController {
    
    func create(_ req: Request) throws -> Future<Private.AwardType> {
        return try req.content.decode(Private.AwardType.self).flatMap { $0.save(on: req) }
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

    func list(_ req: Request) throws -> Future<[Public.AwardType]> {
        return Private.AwardType.query(on: req).all().map { $0.map { $0.toPublic() } }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.AwardType.Delete.self).flatMap { params in
            return Private.AwardType.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
            .delete(on: req)
        }.transform(to: .ok)
    }
}

extension Requests {
    class AwardType {
        struct Delete: Content {
            var id: Int
        }
    }
}
