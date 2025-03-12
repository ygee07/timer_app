//
//  TimerFormView.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//


import SwiftUI
import SwiftData

struct TimerFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CountdownTimer.sequence) private var timers: [CountdownTimer]
    
    let timer: CountdownTimer?
    @State private var title: String
    @State private var duration: Double
    
    init(timer: CountdownTimer? = nil) {
        self.timer = timer
        _title = State(initialValue: timer?.title ?? "")
        _duration = State(initialValue: timer?.duration ?? 300) // Default 5 minutes
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                
                Stepper(
                    value: $duration,
                    in: 60...7200, // 1 minute to 2 hours in seconds
                    step: 60.0
                ) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(duration/60)) minutes")
                    }
                }
            }
            .navigationTitle(timer == nil ? "Add Timer" : "Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(timer == nil ? "Add" : "Save") {
                        saveTimer()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveTimer() {
        withAnimation {
            if let existingTimer = timer {
                // Update existing timer
                existingTimer.title = title
                existingTimer.duration = duration
                existingTimer.elapsedTime = 0
                existingTimer.startTime = nil
                existingTimer.isCompleted = false
            } else {
                // Create new timer
                let newTimer = CountdownTimer(
                    title: title,
                    duration: duration,
                    sequence: timers.count
                )
                modelContext.insert(newTimer)
            }
            dismiss()
        }
    }
}

// End of file. No additional code.
