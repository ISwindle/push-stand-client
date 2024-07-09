import Foundation
import Combine

class CurrentUser: ObservableObject {
    @Published var email: String?
    @Published var uid: String?
    @Published var reminderTime: String?
    @Published var birthdate: String?
    @Published var firebaseAuthToken: String?
    @Published var phoneNumber: String?
    @Published var lastStandDate: Date?
    @Published var lastQuestionAnsweredDate: Date?
    static let shared = CurrentUser()

    private init() {
        email = ""
        uid = ""
        reminderTime = ""
        birthdate = ""
        firebaseAuthToken = ""
        phoneNumber = ""
        lastStandDate = nil
        lastQuestionAnsweredDate = nil
    }
}
