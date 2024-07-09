//
//  TimeHelpers.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/6/24.
//

import Foundation

class Time {
    
    private static let defaultDateFormat = "yyyy-MM-dd"
    
    static func getDateFormatted(daysOffset: Int = 0, dateFormat: String = defaultDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) {
            return dateFormatter.string(from: date)
        } else {
            // Handle the case where the date calculation fails
            return "Error calculating the date"
        }
    }
    
    // Convenience methods for specific use cases
    static func getCurrentDateFormatted() -> String {
        return getDateFormatted(daysOffset: 0)
    }
    
    static func getPreviousDateFormatted() -> String {
        return getDateFormatted(daysOffset: -1)
    }
    
    
    static func isDatePriorToToday(_ date: Date?) -> Bool {
        // Unwrap the optional date
        guard let date = date else {
            // If the date is nil, handle accordingly (e.g., return false or throw an error)
            return false
        }
        
        // Get the current date
        let today = Date()
        
        // Use Calendar to compare dates without time components
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        let startOfInputDate = calendar.startOfDay(for: date)
        
        // Compare the dates
        return startOfInputDate < startOfToday
    }

}


