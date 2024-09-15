import Foundation

/// A class responsible for validating email addresses, phone numbers, and passwords.
/// It allows for dependency injection of validation patterns and rules.
class Validator {
    
    // MARK: - Properties
    
    /// Regular expression pattern used to validate email addresses.
    private let emailRegex: String
    
    /// Regular expression pattern used to validate phone numbers.
    private let phoneNumberPattern: String
    
    /// Minimum required length for a valid password.
    private let minimumPasswordLength: Int
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `Validator` with optional custom validation rules.
    ///
    /// - Parameters:
    ///   - emailRegex: Regular expression pattern for email validation. Defaults to `Constants.emailRegex`.
    ///   - phoneNumberPattern: Regular expression pattern for phone number validation. Defaults to `Constants.phoneNumberPattern`.
    ///   - minimumPasswordLength: Minimum length for password validation. Defaults to `6`.
    init(emailRegex: String = Constants.emailRegex,
         phoneNumberPattern: String = Constants.phoneNumberPattern,
         minimumPasswordLength: Int = 6) {
        self.emailRegex = emailRegex
        self.phoneNumberPattern = phoneNumberPattern
        self.minimumPasswordLength = minimumPasswordLength
    }
    
    // MARK: - Validation Methods
    
    /// Validates whether the provided email address matches the email regex pattern.
    ///
    /// - Parameter email: The email address to validate.
    /// - Returns: `true` if the email is valid; otherwise, `false`.
    func isValidEmail(_ email: String) -> Bool {
        // Create a predicate with the email regex pattern.
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        // Evaluate the email address against the regex pattern.
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates whether the provided phone number matches the phone number regex pattern.
    ///
    /// - Parameter phoneNumber: The phone number to validate.
    /// - Returns: `true` if the phone number is valid; otherwise, `false`.
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Attempt to create a regular expression with the phone number pattern.
        guard let regex = try? NSRegularExpression(pattern: phoneNumberPattern) else {
            // If the regex cannot be created, return false.
            return false
        }
        // Define the range of the phone number string to search within.
        let range = NSRange(phoneNumber.startIndex..., in: phoneNumber)
        // Check if there is at least one match in the phone number string.
        return regex.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    /// Validates whether the provided password meets the minimum length requirement.
    ///
    /// - Parameter password: The password to validate.
    /// - Returns: `true` if the password is valid; otherwise, `false`.
    func isValidPassword(_ password: String) -> Bool {
        // Check if the password length is greater than or equal to the minimum required length.
        return password.count >= minimumPasswordLength
    }
}

