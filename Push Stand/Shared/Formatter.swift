//
//  Formatter.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/7/24.
//

import Foundation

class Formatter {
    
    static func formatLargeNumber(_ number: Int) -> String {
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
    
}
