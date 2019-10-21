//
//  File.swift
//  
//
//  Created by Вова Петров on 18.10.2019.
//

import Vapor
import FluentSQLite

extension Category {
    final class Controller {
        
        func create(_ req: Request) throws -> Future<Model> {
            return try req.content.decode(Model.self).flatMap { $0.save(on: req) }
        }

        func list(_ req: Request) throws -> Future<[Model]> {
            return Model.query(on: req).all()
        }

        func delete(_ req: Request) throws -> Future<HTTPStatus> {
            return try req.content.decode(Model.self).flatMap({ $0.delete(on: req) }).transform(to: .ok)
        }
    }
}
