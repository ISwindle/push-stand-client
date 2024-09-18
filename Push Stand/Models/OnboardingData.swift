import Foundation

class OnboardingData {
    // Singleton instance
    static let shared = OnboardingData()
    
    // Onboarding properties
    var username: String?
    var email: String?
    var password: String?
    var phoneNumber: String?
    var rememberMe: Bool = false
    var birthday: Date?
    var isAgeConfirmed: Bool = false
    var reminderTime: String?
    
    // Private initializer to enforce singleton
    private init() {}

    // MARK: - Setter Methods
    
    /// Sets the username
    func setUsername(_ username: String) {
        // You can add validation logic here if needed
        OnboardingData.shared.username = username
    }
    
    /// Sets the email
    func setEmail(_ email: String) {
        // You can add validation logic (e.g., email format check)
        OnboardingData.shared.email = email
    }
    
    /// Sets the password
    func setPassword(_ password: String) {
        // You can add password validation rules here (e.g., min length)
        OnboardingData.shared.password = password
    }
    
    /// Sets the phone number
    func setPhoneNumber(_ phoneNumber: String) {
        // Perform validation or other logic here if needed
        OnboardingData.shared.phoneNumber = phoneNumber
    }
    
    /// Sets the remember me preference
    func setRememberMe(_ rememberMe: Bool) {
        OnboardingData.shared.rememberMe = rememberMe
    }
    
    /// Sets the birthday
    func setBirthday(_ birthday: Date) {
        OnboardingData.shared.birthday = birthday
    }
    
    /// Sets the age confirmation status
    func setAgeConfirmed(_ isAgeConfirmed: Bool) {
        OnboardingData.shared.isAgeConfirmed = isAgeConfirmed
    }
    
    /// Sets the reminder time
    func setReminderTime(_ reminderTime: String) {
        OnboardingData.shared.reminderTime = reminderTime
    }
}
