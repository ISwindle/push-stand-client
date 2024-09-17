import Foundation
import Combine

class SessionViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var sessionToken: String?
    @Published var isLoading: Bool = false
    @Published var currentUser: CurrentUser = CurrentUser.shared
    @Published var standModel: StandModel = StandModel.shared
    @Published var dailyQuestionModel: DailyQuestionModel = DailyQuestionModel.shared
    @Published var badgeCount: Int? = 0
    @Published var questionItemBadgeCount: Int? = 0

    private var cancellables = Set<AnyCancellable>()
    var userManager: UserManager
    
    static let shared = SessionViewModel(userManager: UserManager())

    init(userManager: UserManager = UserManager()) {
        self.userManager = userManager
        loadSession()
    }

    func login(userName: String, password: String) {
        self.isLoading = true
        // Simulate a network call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.userName = userName
            self.sessionToken = "example_token"
            self.isLoggedIn = true
            self.isLoading = false

            // Update current user information
            let user = User(email: "user@example.com",
                            uid: "12345",
                            reminderTime: "08:00 AM",
                            birthdate: "01/01/1990",
                            firebaseAuthToken: "example_token",
                            phoneNumber: "123-456-7890",
                            lastStandDate: Date(),
                            lastQuestionAnsweredDate: Date(),
                            userNumber: "0")
            self.userManager.loginUser(with: user)

            // Initialize or update StandModel data if needed
            self.updateStandModel()
            self.updateDailyQuestionModel()

            self.saveSession()
        }
    }

    func logout() {
        self.isLoading = true
        // Simulate a network call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.userName = ""
            self.sessionToken = nil
            self.isLoggedIn = false
            self.isLoading = false

            // Clear current user information
            self.userManager.logoutUser()

            // Clear StandModel and DailyQuestionModel data if needed
            self.clearStandModel()
            self.clearDailyQuestionModel()

            self.clearSession()
        }
    }

    private func loadSession() {
        self.isLoading = true
        // Simulate a network call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let savedUserName = UserDefaults.standard.string(forKey: "userName"),
               let savedToken = UserDefaults.standard.string(forKey: "sessionToken") {
                self.userName = savedUserName
                self.sessionToken = savedToken
                self.isLoggedIn = true

                // Update current user information from persistent storage if needed
                // This part can be customized based on how you store user data
                self.updateStandModel()
                self.updateDailyQuestionModel()
            }
            self.isLoading = false
        }
    }

    private func saveSession() {
        UserDefaults.standard.set(self.userName, forKey: "userName")
        UserDefaults.standard.set(self.sessionToken, forKey: "sessionToken")

        // Save current user information to persistent storage if needed
        // This part can be customized based on how you store user data
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "sessionToken")

        // Clear current user information from persistent storage if needed
        // This part can be customized based on how you store user data
    }

    private func updateStandModel() {
        // Simulate updating StandModel data from a network call or local storage
        standModel.dailyGoal = 10
        standModel.americansStandingToday = 1000
        standModel.yesterdaysStanding = 8
        standModel.myPoints = 50
        standModel.myStandStreak = 5
        standModel.myTotalStands = 200
        standModel.usaTotalStands = 100000
    }

    private func clearStandModel() {
        standModel.dailyGoal = 0
        standModel.americansStandingToday = 0
        standModel.yesterdaysStanding = 0
        standModel.myPoints = 0
        standModel.myStandStreak = 0
        standModel.myTotalStands = 0
        standModel.usaTotalStands = 0
    }

    private func updateDailyQuestionModel() {
        // Fetch the daily question and other related data
        dailyQuestionModel.fetchDailyQuestion()
        dailyQuestionModel.fetchYesterdaysQuestion()
        dailyQuestionModel.fetchQuestionStreak()
    }

    private func clearDailyQuestionModel() {
        dailyQuestionModel.dailyQuestion = ""
        dailyQuestionModel.yesterdaysQuestion = ""
        dailyQuestionModel.truePercentage = 0
        dailyQuestionModel.falsePercentage = 0
        dailyQuestionModel.answerStreak = 0
        dailyQuestionModel.activeAnswer = false
    }
}
