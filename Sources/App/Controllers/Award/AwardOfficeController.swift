//
//  AwardOfficeController.swift
//  
//
//  Created by Вова Петров on 19.04.2020.
//

import Vapor
import FluentSQLite

final class AwardOfficeController {

    func create(_ req: Request) throws -> Future<Private.AwardOffice> {
        let user = try req.requireAuthenticated(Private.User.self)
        guard Access.modifyAward.available(user.role) else {
            throw Abort.init(.methodNotAllowed)
        }
        
        return try req.content.decode(Private.AwardOffice.self).flatMap { office in
            return office.save(on: req)
        }
    }

    func list(_ req: Request) throws -> Future<[Private.AwardOffice]> {
        return Private.AwardOffice.query(on: req).all()
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
        struct Delete: Content {
            var id: Int
        }
    }
}
