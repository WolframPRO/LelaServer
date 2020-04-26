//
//  AwardController.swift
//
//
//  Created by Вова Петров on 23.01.2020.
//

import Vapor
import FluentSQLite

final class AwardController {
    func create(_ req: Request) throws -> Future<Public.Award> {
        return try req.content.decode(Requests.Award.Create.self).flatMap { params in
            let user = try req.requireAuthenticated(Private.User.self)
            return Private.AwardType.find(params.typeId, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { type in
                    guard type.isAvailable, let userId = user.id else { throw Abort(HTTPResponseStatus.notModified) }
                    user.balance = user.balance - type.price
                    return user.save(on: req).flatMap { user in
                        return Private.Award(type: type, ownerId: userId).save(on: req).map { $0.toPublic() }
                    }
            }
        }
    }
    
    func change(_ req: Request) throws -> Future<Public.Award> {
        let user = try req.requireAuthenticated(Private.User.self)
        guard Access.modifyAward.available(user.role) else {
            throw Abort.init(.methodNotAllowed)
        }
        
        return try req.content.decode(Requests.Award.Change.self).flatMap { params in
            return Private.Award.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { $0.change(params).save(on: req).map { award in
                    return award.toPublic()
                }
            }
        }
    }
    
    func list(_ req: Request) throws -> Future<[Public.Award]> {
        return try req.content.decode(Requests.Award.List.self).flatMap { params in
            let query = Private.Award.query(on: req).all()
            return query.map { awards in
                awards.filter { award in
                    if let ownerId = params.ownerId {
                        if award.ownerId != ownerId { return false }
                    }
                    if let typeId = params.typeId {
                        if award.typeId != typeId { return false }
                    }
                    return true
                }.map { $0.toPublic() }
            }
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.Award> {
        return try req.content.decode(Requests.Award.Index.self).flatMap { params in
            return Private.Award.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.Award.Delete.self).flatMap { params in
            return Private.Award.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
            .delete(on: req)
        }.transform(to: .ok)
    }
}

extension Requests {
    class Award {
        struct Create: Content {
            var typeId: Int
        }
        struct Change: Content {
            var id: Int
            
            var operatorId: Int?
            var status: Int
        }
        
        struct Index: Content {
            var id: Int
        }
        
        struct Delete: Content {
            var id: Int
        }
        
        struct List: Codable {
            var ownerId: Int?
            var typeId: Int?
        }
    }
}
