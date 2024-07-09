//
//  Validator.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/7/24.
//

import Foundation

class Validator {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // This pattern matches exactly 10 digits
            let pattern = "^\\d{10,11}$"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: phoneNumber.utf16.count)
            return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        let minimumPasswordLength = 6
        return password.count >= minimumPasswordLength
    }

}
