//
//  TimeHelpers.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/6/24.
//

import Foundation

class Time {
    
    static let errorDateCalculationMessage = "Error calculating the date"
    
    static func getDateFormatted(daysOffset: Int = 0, dateFormat: String = Constants.defaultDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) {
            return dateFormatter.string(from: date)
        } else {
            return errorDateCalculationMessage
        }
    }
    
    static func getPacificDateFormatted(daysOffset: Int = 0, dateFormat: String = Constants.defaultDateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        // Set the time zone to Pacific Time (PST/PDT)
        dateFormatter.timeZone = TimeZone(identifier: Constants.defaultTimezone)
        
        // Ensure the calendar is using Pacific Time as well
        var pacificCalendar = Calendar.current
        pacificCalendar.timeZone = TimeZone(identifier: Constants.defaultTimezone)!

        // Calculate the date with the days offset
        if let date = pacificCalendar.date(byAdding: .day, value: daysOffset, to: Date()) {
            return dateFormatter.string(from: date)
        } else {
            // Handle the case where the date calculation fails
            return errorDateCalculationMessage
        }
    }

    
    // Convenience methods for specific use cases
    static func getCurrentDateFormatted() -> String {
        return getDateFormatted(daysOffset: 0)
    }
    
    // Convenience methods for specific use cases
    static func getPacificCurrentDateFormatted() -> String {
        return getPacificDateFormatted(daysOffset: 0)
    }
    
    
    static func getPreviousDateFormatted() -> String {
        return getDateFormatted(daysOffset: -1)
    }
    
    static func getPacificPreviousDateFormatted() -> String {
        return getPacificDateFormatted(daysOffset: -1)
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


