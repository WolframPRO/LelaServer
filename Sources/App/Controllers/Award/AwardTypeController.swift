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
    
    func change(_ req: Request) throws -> Future<Public.AwardType> {
        return try req.content.decode(Requests.AwardType.Change.self).flatMap { params in
            return Private.AwardType.find(params.id, on: req)
            .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .flatMap { $0.change(params).save(on: req).map { awardType in
                    return awardType.toPublic()
                }
            }
        }
    }

    func list(_ req: Request) throws -> Future<[Public.AwardType]> {
        return try req.content.decode(Requests.AwardType.List.self).flatMap { params in
            let query = Private.AwardType.query(on: req).all()
            return query.map { $0.filter { !params.availableOnly || $0.isAvailable }.map { $0.toPublic() } }
        }
    }
    
    func index(_ req: Request) throws -> Future<Public.AwardType> {
        return try req.content.decode(Requests.AwardType.Index.self).flatMap { params in
            return Private.AwardType.find(params.id, on: req)
                .unwrap(or: Abort(HTTPResponseStatus.notFound))
                .map { $0.toPublic() }
        }
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
        struct Index: Content {
            var id: Int
        }
        struct Delete: Content {
            var id: Int
        }
        struct Change: Content {
            var id: Int
            
            var title: String
            var description: String
            var isAvailable: Bool
            var price: Int

            var imageUrl: String?
        }
        
        struct List: Content {
            var availableOnly: Bool
        }
    }
}
