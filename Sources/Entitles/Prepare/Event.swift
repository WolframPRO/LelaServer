//
//  Event.swift
//  Lela
//
//  Created by варя on 21/05/2019.
//  Copyright © 2019 варя. All rights reserved.
//

import Foundation
import UIKit

struct Event {
    var id: Int
    var title: String
    var points: Int
    var periodArray: Period
    var capacity: Int? //max peope
    
    var categoryId: Int
    var category: Parent<Event, Category.Model> {
        return parent(\.categoryId)
    }
    
    var ownerId: Int
    var owner: Parent<Event, User> {
        return parent(\.personIdOwner)
    }
    
    var partsId: [Int]
    var notesId: [Int]
    var photoId: [Int]
}

struct Period {
    var startDate: Date
    var endDate: Date
}
