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
        if user.role == 1 {}
        return try req.content.decode(Private.AwardOffice.self).flatMap { $0.save(on: req) }
    }

    func list(_ req: Request) throws -> Future<[Private.AwardOffice]> {
        return Private.AwardOffice.query(on: req).all()
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.AwardOffice.Delete.self).flatMap { params in
            return Private.Category.find(params.id, on: req)
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
