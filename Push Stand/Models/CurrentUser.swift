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

    private init() { }

    func update(with user: User) {
        self.email = user.email
        self.uid = user.uid
        self.reminderTime = user.reminderTime
        self.birthdate = user.birthdate
        self.firebaseAuthToken = user.firebaseAuthToken
        self.phoneNumber = user.phoneNumber
        self.lastStandDate = user.lastStandDate
        self.lastQuestionAnsweredDate = user.lastQuestionAnsweredDate
    }

    func clear() {
        self.email = nil
        self.uid = nil
        self.reminderTime = nil
        self.birthdate = nil
        self.firebaseAuthToken = nil
        self.phoneNumber = nil
        self.lastStandDate = nil
        self.lastQuestionAnsweredDate = nil
    }
}

struct User {
    let email: String?
    let uid: String?
    let reminderTime: String?
    let birthdate: String?
    let firebaseAuthToken: String?
    let phoneNumber: String?
    let lastStandDate: Date?
    let lastQuestionAnsweredDate: Date?
}
