//
//  ContentView.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import SwiftUI
import SwiftData
import SwiftDate

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CountdownTimer.sequence) private var timers: [CountdownTimer]

    // Add timer control state
    @State private var currentTimer: CountdownTimer?
    @State private var timerCheckTask: Task<Void, Never>?
    @State private var currentIndex: Int = 0

    var body: some View {
        NavigationStack {
            TimelineView(.animation(minimumInterval: 0.1)) { _ in
                List {
                    ForEach(Array(timers.enumerated()), id: \.element.id) { index, timer in
                        CountdownTimerItem(timer: timer)
                    }
                    .onDelete(perform: deleteTimers)
                    .onMove(perform: moveTimers)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        EditButton()
                            .labelStyle(.iconOnly)
                        
                        Spacer()
                        
                        Button(action: toggleCurrentTimer) {
                            Label(
                                currentTimer?.isActive == true ? "Pause" : "Start",
                                systemImage: currentTimer?.isActive == true ? "pause" : "play"
                            )
                            
                        }
                        .labelStyle(.iconOnly)
                        .disabled(timers.isEmpty)
                        
                        Spacer()
                        Button(action: addTimer) {
                            Label("Add Timer", systemImage: "plus")
                        }
                        .labelStyle(.iconOnly)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background {
                        Capsule()
                            .fill(Material.ultraThick)
                    }
                    .padding()
                }
            }
        }
        .onDisappear {
            timerCheckTask?.cancel()
        }
        // Remove isActive onChange and only keep remainingTime monitoring
        .onChange(of: currentTimer?.remainingTime) { _, _ in
            checkTimerCompletion()
        }
        .onAppear {
            if !timers.isEmpty && currentTimer == nil {
                currentIndex = 0
                currentTimer = timers[currentIndex]
            }
        }
    }

    private func addTimer() {
        withAnimation {
            let newTimer = CountdownTimer(
                title: UUID().uuidString,
                duration: 3,
                sequence: timers.count
            )
            modelContext.insert(newTimer)
        }
    }

    private func deleteTimers(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(timers[index])
            }
            // Update sequences after deletion
            for (index, timer) in timers.enumerated() {
                timer.sequence = index
            }
            
            // If the current timer was deleted, reset to the first timer
            if currentTimer == nil || !timers.contains(where: { $0.id == currentTimer?.id }) {
                currentIndex = 0
            }
        }
    }

    private func moveTimers(from source: IndexSet, to destination: Int) {
        var updatedTimers = timers
        updatedTimers.move(fromOffsets: source, toOffset: destination)
        
        for (index, timer) in updatedTimers.enumerated() {
            timer.sequence = index
        }
        
        // Update currentIndex if needed
        if let currentTimer = currentTimer, let newIndex = timers.firstIndex(where: { $0.id == currentTimer.id }) {
            currentIndex = newIndex
        }
    }
    
    /// Toggles the active state of the current timer
    /// Handles the timer's elapsed time calculation and start/pause state
    /// When all timers are completed, resets all timers and starts from the first one
    private func toggleCurrentTimer() {
        // Check if we need to reset all timers
        if (currentTimer == nil || timers.allSatisfy({ $0.isCompleted })) && !timers.isEmpty {
            // Reset all timers
            for timer in timers {
                timer.elapsedTime = 0
                timer.isActive = false
                timer.startTime = nil
                timer.isCompleted = false
            }
            
            // Set the first timer as current
            currentIndex = 0
            currentTimer = timers[currentIndex]
            
            // Save changes
            try? modelContext.save()
        } else if currentTimer == nil && !timers.isEmpty {
            // Initialize current timer if needed but timers aren't all completed
            currentIndex = 0
            currentTimer = timers[currentIndex]
        }
        
        guard let timer = currentTimer else { return }
        
        if timer.isActive {
            // Pausing - accumulate elapsed time
            if let startTime = timer.startTime {
                timer.elapsedTime += Date().timeIntervalSince(startTime)
            }
            timer.startTime = nil
            timerCheckTask?.cancel()
        } else {
            // Starting - set new start time
            timer.startTime = Date()
            startTimerCheckTask()
        }
        timer.isActive.toggle()
    }
    
    /// Creates a background task to monitor the current timer's status
    /// The task checks timer completion every 0.1 seconds
    private func startTimerCheckTask() {
        // Cancel any existing task
        timerCheckTask?.cancel()
        
        // Create a new task that checks the timer status regularly
        timerCheckTask = Task {
            while !Task.isCancelled {
                // Check if we should move to the next timer
                if let timer = currentTimer,
                   timer.isActive,
                   timer.remainingTime <= 0 {
                    // Execute on the main thread since we're updating UI
                    await MainActor.run {
                        handleTimerCompletion(timer)
                    }
                }
                
                // Wait a short time before checking again
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
        }
    }
    
    /// Verifies if the current timer has completed its duration
    /// Triggers timer completion handling if necessary
    private func checkTimerCompletion() {
        guard let timer = currentTimer,
              timer.isActive,
              timer.remainingTime <= 0 else { return }
        
        handleTimerCompletion(timer)
    }

    /// Processes a completed timer and sets up the next timer in sequence
    /// - Parameter timer: The timer that has completed its duration
    /// Saves the changes to the model context and updates timer states
    private func handleTimerCompletion(_ timer: CountdownTimer) {
        timer.isActive = false
        timer.isCompleted = true
        timer.startTime = nil
        timer.elapsedTime = timer.duration
        
        // Cancel the current timer check task
        timerCheckTask?.cancel()
        
        // Find the next timer in sequence
        if let currentIndex = timers.firstIndex(where: { $0.id == timer.id }),
           currentIndex + 1 < timers.count {
            let nextTimer = timers[currentIndex + 1]
            currentTimer = nextTimer
            self.currentIndex = currentIndex + 1
            
            // Reset and start the next timer
            nextTimer.elapsedTime = 0
            nextTimer.isActive = true
            nextTimer.startTime = Date()
            nextTimer.isCompleted = false
            
            // Start a new timer check task
            startTimerCheckTask()
        } else {
            // All timers completed
            currentTimer = nil
        }
        
        // Save changes to the database
        do {
            try modelContext.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
