import UIKit

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let questionAnsweredKey = "questionAnswered"
    
    func setQuestionAnswered(_ answered: Bool) {
        UserDefaults.standard.set(answered, forKey: questionAnsweredKey)
        UserDefaults.standard.synchronize()
    }
    
    func isQuestionAnswered() -> Bool {
        return UserDefaults.standard.bool(forKey: questionAnsweredKey)
    }
    
}
