//
//  Timer.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import Foundation
import SwiftData
import SwiftDate

/// A model representing a countdown timer with sequence management
@Model
final class CountdownTimer {
    /// The display name of the timer
    var title: String
    /// The total length of the timer in seconds
    var duration: TimeInterval
    /// The timestamp when the timer was last started (nil when paused or not started)
    var startTime: Date?
    /// The accumulated time the timer has been running (used to handle pauses)
    var elapsedTime: TimeInterval
    /// Indicates whether the timer has reached its completion
    var isCompleted: Bool
    /// Position in the execution order of multiple timers
    var sequence: Int
    /// Indicates whether the timer is currently counting down
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
    
    /// The remaining time left before the timer completes (in seconds)
    /// Takes into account both accumulated elapsed time and current running time
    var remainingTime: TimeInterval {
        guard isActive, let startTime = startTime else { return duration - elapsedTime }
        let currentElapsed = elapsedTime + Date().timeIntervalSince(startTime)
        return max(0, duration - currentElapsed)
    }
    
    /// The completion percentage as a value between 0 and 1
    /// 0 means not started, 1 means fully completed
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
