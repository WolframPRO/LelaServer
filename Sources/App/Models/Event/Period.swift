//
//  File.swift
//  
//
//  Created by Вова Петров on 22.10.2019.
//

import FluentSQLite
import Vapor

extension Public {
    struct Period: Content {
        var id: Int
        var startDate: Date
        var endDate: Date
    }
}

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
        
        func toPublic() -> Public.Period {
            return Public.Period(id: id!, startDate: startDate, endDate: endDate)
        }
    }
}

extension Private.Period: Migration { }
extension Private.Period: Content { }
extension Private.Period: Parameter { }
