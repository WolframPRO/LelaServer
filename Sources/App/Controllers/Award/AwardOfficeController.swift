//
//  AwardOfficeController.swift
//  
//
//  Created by Вова Петров on 19.04.2020.
//

import Vapor
import FluentSQLite

final class AwardOfficeController {

    func create(_ req: Request) throws -> Future<Public.AwardOffice> {
        let user = try req.requireAuthenticated(Private.User.self)
        guard Access.modifyAward.available(user.role) else {
            throw Abort.init(.methodNotAllowed)
        }
        
        return try req.content.decode(Private.AwardOffice.self).flatMap { office in
            return office.save(on: req).map { $0.toPublic() }
        }
    }
    
    func change(_ req: Request) throws -> Future<Public.AwardOffice> {
        return try req.content.decode(Requests.AwardOffice.Change.self).flatMap { params in
            return Private.AwardOffice.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { $0.change(params).save(on: req).map { awardOffice in
                    return awardOffice.toPublic()
                }
            }
        }
    }

    func list(_ req: Request) throws -> Future<[Public.AwardOffice]> {
        return Private.AwardOffice.query(on: req).all().map { $0.map { $0.toPublic() } }
    }
    
    func index(_ req: Request) throws -> Future<Public.AwardOffice> {
        return try req.content.decode(Requests.AwardOffice.Index.self).flatMap { params in
            return Private.AwardOffice.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(Private.User.self)
        guard Access.modifyAward.available(user.role) else {
            throw Abort.init(.methodNotAllowed)
        }
        
        return try req.content.decode(Requests.AwardOffice.Delete.self).flatMap { params in
            return Private.AwardOffice.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
            .delete(on: req)
        }.transform(to: .ok)
    }
}

extension Requests {
    class AwardOffice {
        struct Index: Content {
            var id: Int
        }
        struct Delete: Content {
            var id: Int
        }
        struct Change: Content {
            var id: Int

            var address: String
            var operatorFio: String
            var timetable: String
        }
    }
}
