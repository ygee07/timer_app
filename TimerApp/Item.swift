//
//  Item.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
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
