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
    @Query private var timers: [CountdownTimer]

    var body: some View {
        NavigationStack {
            List {
                ForEach(timers) { timer in
                    NavigationLink {
                        VStack {
                            Text(timer.title)
                            Text("Duration: \(Int(timer.duration)) seconds")
                            Text("Remaining: \(Int(timer.remainingTime)) seconds")
                            Text("Progress: \(Int(timer.progress * 100))%")
                            
                            Button(timer.isActive ? "Pause" : "Start") {
                                timer.isActive.toggle()
                                if timer.isActive {
                                    timer.startTime = Date()
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(timer.title)
                            Spacer()
                            Text("\(Int(timer.remainingTime))s")
                        }
                    }
                }
                .onDelete(perform: deleteTimers)
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CountdownTimer.self, inMemory: true)
}
