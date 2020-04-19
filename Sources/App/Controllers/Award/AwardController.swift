//
//  AwardController.swift
//
//
//  Created by Вова Петров on 23.01.2020.
//

import Vapor
import FluentSQLite

final class AwardController {

    func create(_ req: Request) throws -> Future<Private.Award> {
        return try req.content.decode(Private.Award.self).flatMap { $0.save(on: req) }
    }

    func list(_ req: Request) throws -> Future<[Private.Award]> {
        return Private.Award.query(on: req).all()
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.Award.Delete.self).flatMap { params in
            return Private.Category.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.alreadyReported))
            .delete(on: req)
        }.transform(to: .ok)
    }
}

extension Requests {
    class Award {
        struct Delete: Content {
            var id: Int
        }
    }
}
