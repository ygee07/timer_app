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

    var body: some View {
        NavigationStack {
            List {
                ForEach(timers) { timer in
                    CountdownTimerItem(timer: timer)
                }
                .onDelete(perform: deleteTimers)
                .onMove(perform: moveTimers)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addTimer) {
                        Label("Add Timer", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addTimer() {
        withAnimation {
            let newTimer = CountdownTimer(
                title: "New Timer",
                duration: 60,
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
        }
    }

    private func moveTimers(from source: IndexSet, to destination: Int) {
        var updatedTimers = timers
        updatedTimers.move(fromOffsets: source, toOffset: destination)
        
        for (index, timer) in updatedTimers.enumerated() {
            timer.sequence = index
        }
    }
}
