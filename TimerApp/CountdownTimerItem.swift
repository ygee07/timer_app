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
        detailView
    }
    
    private var detailView: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { _ in
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("\(formatTime(timer.remainingTime))")
                            .font(.largeTitle)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(Int(timer.duration)) seconds")
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                    Text(timer.title)
                }
                
                ProgressView(value: timer.progress)
                    .tint(timer.isActive ? .blue : (timer.isCompleted ? .green : .gray))
            }
            .padding()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
