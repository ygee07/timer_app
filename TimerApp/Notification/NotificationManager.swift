//
//  NotificationManager.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import UserNotifications
import SwiftUI

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    private var isAuthorized = false
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            self.isAuthorized = granted
        }
    }
    
    func scheduleTimerCompletionNotification(title: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(title) has finished!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
