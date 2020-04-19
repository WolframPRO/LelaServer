//
//  File.swift
//  
//
//  Created by Вова Петров on 19.04.2020.
//

import Foundation

enum Access: Int {
    
    case modifyCategory = 0b1000000
    case modifyAward = 0b0100000
    case adminAward = 0b0010000
    case manageUserRole = 0b0001000
    
    func available(_ value: Int) -> Bool {
        value & self.rawValue != 0
    }
}
