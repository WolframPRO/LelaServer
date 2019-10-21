//
//  Note.swift
//  Lela
//
//  Created by Вова Петров on 13.08.2019.
//  Copyright © 2019 варя. All rights reserved.
//

import Foundation

struct Note {
    let id: Int
    let theme: String?
    let text: String
    let time: Date
    let personId: Int
    let isAnonimus: Bool
    let attachmentId: Int?
    let eventId: Int
}
