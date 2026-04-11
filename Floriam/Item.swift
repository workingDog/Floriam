//
//  Item.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
