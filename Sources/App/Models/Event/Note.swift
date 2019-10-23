//
//  Note.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import FluentSQLite
import Vapor

extension Private {
    final class Note: SQLiteModel {
        
        var id: Int?
        var number: Int
        var theme: String?
        var text: String
        var time: Date
        var personId: Int
        var isAnonimus: Bool
        
        var attachmentId: Int?
        
        
        init(id: Int?, number: Int, theme: String?, text: String, time: Date, personId: Int, isAnonimus: Bool, attachmentId: Int?) {
            self.id = id
            self.number = number
            self.theme = theme
            self.text = text
            self.time = time
            self.personId = personId
            self.isAnonimus = isAnonimus
            self.attachmentId = attachmentId
        }
        
    }
}

extension Private.Note: Migration { }
extension Private.Note: Content { }
extension Private.Note: Parameter { }
