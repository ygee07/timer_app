//
//  RepeatOptionsView.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import SwiftUI

struct RepeatOptionsView: View {
 @Binding var shouldRepeatTimers: Bool
 @Binding var repeatInterval: TimeInterval
 @Environment(\.dismiss) private var dismiss
 
 var body: some View {
     NavigationStack {
         Form {
             Section {
                 Toggle("Repeat Timers", isOn: $shouldRepeatTimers)
             }
             
             if shouldRepeatTimers {
                 Section(header: Text("Repeat Interval (minutes)")) {
                     Stepper(value: $repeatInterval, in: 1...60) {
                         Text("\(Int(repeatInterval)) minute\(repeatInterval == 1 ? "" : "s")")
                     }
                 }
             }
         }
         .navigationTitle("Repeat Options")
         .navigationBarTitleDisplayMode(.inline)
         .toolbar {
             ToolbarItem(placement: .confirmationAction) {
                 Button("Done") {
                     dismiss()
                 }
             }
         }
     }
     .presentationDetents([.medium])
 }
}
