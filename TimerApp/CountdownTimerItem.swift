//
//  CountdownTimerItem.swift
//  TimerApp
//
//  Created by Yhanco Grey Esteban on 3/12/25.
//

import SwiftUI
import SwiftDate

struct CountdownTimerItem: View {
    let timer: CountdownTimer
    
    var body: some View {
        NavigationLink {
            detailView
        } label: {
            listItemView
        }
    }
    
    private var detailView: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { _ in
            VStack {
                Text(timer.title)
                Text("Duration: \(Int(timer.duration)) seconds")
                Text("Remaining: \(Int(timer.remainingTime)) seconds")
                Text("Progress: \(Int(timer.progress * 100))%")
                
                Button(timer.isActive ? "Pause" : "Start") {
                    if timer.isActive {
                        // Pausing - accumulate elapsed time
                        if let startTime = timer.startTime {
                            timer.elapsedTime += Date().timeIntervalSince(startTime)
                        }
                        timer.startTime = nil
                    } else {
                        // Starting - set new start time
                        timer.startTime = Date()
                    }
                    timer.isActive.toggle()
                }
            }
        }
    }
    
    private var listItemView: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { _ in
            HStack {
                Text(timer.title)
                Spacer()
                Text("\(Int(timer.remainingTime))s")
            }
        }
    }
}

// End of file. No additional code.
