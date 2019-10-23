//
//  File.swift
//  
//
//  Created by Вова Петров on 22.10.2019.
//

import FluentSQLite
import Vapor

extension Private {
    final class Period: SQLiteModel {
        var id: Int?
        var startDate: Date
        var endDate: Date
        
        init(id: Int? = nil, startDate: Date, endDate: Date) {
            self.id = id
            self.startDate = startDate
            self.endDate = endDate
        }
    }
}

extension Private.Period: Migration { }
extension Private.Period: Content { }
extension Private.Period: Parameter { }
