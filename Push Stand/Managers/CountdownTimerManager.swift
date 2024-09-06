//
//  CountdownTimerManager.swift
//  Push Stand
//
//  Created by Isaac Swindle on 9/6/24.
//

import Foundation

class CountdownTimerManager {
    static let shared = CountdownTimerManager()
    
    private var countdownTimer: Timer?
    var remainingTime: TimeInterval = 0
    
    private init() {}
    
    func startCountdown() {
        // Update immediately
        updateRemainingTime()
        
        // Start the timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateRemainingTime() {
        let now = Date()
        
        // PST timezone
        let timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let calendar = Calendar.current
        
        // Define the next midnight in PST timezone
        var midnightComponents = calendar.dateComponents(in: timeZone, from: now)
        midnightComponents.day! += 1
        midnightComponents.hour = 0
        midnightComponents.minute = 0
        midnightComponents.second = 0
        
        guard let midnight = calendar.date(from: midnightComponents) else { return }
        
        // Calculate time difference
        remainingTime = midnight.timeIntervalSince(now)
        
        // Notify observers
        if remainingTime <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
