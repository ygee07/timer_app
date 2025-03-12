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
    }
    
    private var listItemView: some View {
        HStack {
            Text(timer.title)
            Spacer()
            Text("\(Int(timer.remainingTime))s")
        }
    }
}

// End of file. No additional code.
