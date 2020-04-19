//
//  CategoryController.swift
//  
//
//  Created by Вова Петров on 18.10.2019.
//

import Vapor
import FluentSQLite

final class CategoryController {
    
    func create(_ req: Request) throws -> Future<Private.Category> {
        return try req.content.decode(Private.Category.self).flatMap { $0.save(on: req) }
    }

    func list(_ req: Request) throws -> Future<[Private.Category]> {
        return Private.Category.query(on: req).all()
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(Requests.Category.Delete.self).flatMap { params in
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
