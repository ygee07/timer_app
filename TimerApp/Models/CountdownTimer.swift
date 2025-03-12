//
//  Timer.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import Foundation
import SwiftData
import SwiftDate

@Model
final class CountdownTimer {
    var title: String
    var duration: TimeInterval
    var startTime: Date?
    /// Tracks if the timer finished
    var elapsedTime: TimeInterval
    /// Tracks if the timer finished
    var isCompleted: Bool
    /// Order in the timer queue
    var sequence: Int
    /// Whether the timer is currently running
    var isActive: Bool
    
    init(
        title: String,
        duration: TimeInterval,
        sequence: Int
    ) {
        self.title = title
        self.duration = duration
        self.sequence = sequence
        self.isCompleted = false
        self.isActive = false
        self.startTime = nil
        self.elapsedTime = 0
    }
    
    var remainingTime: TimeInterval {
        guard isActive, let startTime = startTime else { return duration - elapsedTime }
        let currentElapsed = elapsedTime + Date().timeIntervalSince(startTime)
        return max(0, duration - currentElapsed)
    }
    
    var progress: Double {
        return 1 - (remainingTime / duration)
    }
}

// MARK: - Comparable
extension CountdownTimer: Comparable {
    static func < (lhs: CountdownTimer, rhs: CountdownTimer) -> Bool {
        lhs.sequence < rhs.sequence
    }
}
