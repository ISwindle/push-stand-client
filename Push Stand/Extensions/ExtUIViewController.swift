//
//  ExtViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 1/20/24.
//

import UIKit

extension UIViewController {
    
    func postPoints(queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
            // Call the request method of NetworkService
            NetworkService.shared.request(endpoint: .points, method: "POST", queryParams: queryParams, completion: completion)
    }
    
    func tapHaptic() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func getDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
    func getPreviousDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Create a Calendar instance
        let calendar = Calendar.current
        
        // Get the date for one day before today
        if let dayBeforeToday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            let dateString = dateFormatter.string(from: dayBeforeToday)
            return dateString
        } else {
            // Handle the case where the date calculation fails
            return "Error calculating the previous day"
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // This pattern matches exactly 10 digits
            let pattern = "^\\d{10,11}$"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: phoneNumber.utf16.count)
            return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let minimumPasswordLength = 6
        return password.count >= minimumPasswordLength
    }
    
    func formatLargeNumber(_ number: Int) -> String {
        // Create a number formatter to format the number with decimal style
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        // Convert and format the number based on its size
        if number >= 1_000_000_000 {
            let billion = Double(number) / 1_000_000_000
            return "\(formatter.string(from: NSNumber(value: billion)) ?? "")B"
        } else if number >= 1_000_000 {
            let million = Double(number) / 1_000_000
            return "\(formatter.string(from: NSNumber(value: million)) ?? "")M"
        } else if number >= 1_000 {
            let thousand = Double(number) / 1_000
            return "\(formatter.string(from: NSNumber(value: thousand)) ?? "")K"
        } else {
            return "\(number)"
        }
    }
    
    struct Event: Codable {
        let eventDate: Date
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}
