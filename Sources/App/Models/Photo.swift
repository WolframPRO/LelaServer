//
//  Photo.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

final class Photo: SQLiteModel {
    var id: Int?
//    let image: CGImage
    var description: String?
    var personId: Int
    
    internal init(id: Int?, description: String?, personId: Int) {
        self.id = id
        self.description = description
        self.personId = personId
    }
}

extension Photo: Migration { }
extension Photo: Content { }
extension Photo: Parameter { }
