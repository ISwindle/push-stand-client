//
//  ExtAppDelegate.swift
//  Push Stand
//
//  Created by Isaac Swindle on 9/20/24.
//

import Foundation
import UIKit


extension AppDelegate {
    
    func scheduleLocalNotification() {
            // Create the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "New Day, New Actions!"
            content.body = "It's a new day! Don't forget to complete your actions."
            content.sound = .default
            
            // Set the time to midnight Pacific Time (UTC-8 or UTC-7 depending on DST)
            var dateComponents = DateComponents()
            dateComponents.hour = 0  // Midnight
            dateComponents.minute = 0
            dateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
            
            // Create a trigger to fire every day at midnight
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the request
            let request = UNNotificationRequest(identifier: "MidnightResetNotification", content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }

    
    func resetDailyActions() {
        let midnightDate = Calendar.current.startOfDay(for: Date())
        let lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date ?? Date.distantPast
        
        // Check if the last reset was before today's midnight
        if lastResetDate < midnightDate {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.appStateViewModel.setAppBadgeCount(to: 2)  // Set badge count to 2 (two actions to complete)
            
            // Save the new reset date
            UserDefaults.standard.set(midnightDate, forKey: "LastResetDate")
            UserDefaults.standard.synchronize()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // When app becomes active, check and reset if needed
        resetDailyActions()
    }
}
