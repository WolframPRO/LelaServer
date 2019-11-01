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
        var eventId: Int
        var startDate: Date
        var endDate: Date
    }
}

extension Private {
    final class Period: SQLiteModel {
        var id: Int?
        var eventId: Int
        var startDate: Date
        var endDate: Date
        
        init(id: Int? = nil, eventId: Int, startDate: Date, endDate: Date) {
            self.id = id
            self.eventId = eventId
            self.startDate = startDate
            self.endDate = endDate
        }
        
        func toPublic() -> Public.Period {
            return Public.Period(id: id!, eventId: eventId, startDate: startDate, endDate: endDate)
        }
    }
}

extension Private.Period: Migration { }
extension Private.Period: Content { }
extension Private.Period: Parameter { }
