import SwiftUI
import Combine

class DailyQuestionModel: ObservableObject {
    
    // Singleton instance
    static let shared = DailyQuestionModel()
    
    @Published var dailyQuestion: String = ""
    @Published var yesterdaysQuestion: String = ""
    @Published var truePercentage: Int = 0
    @Published var falsePercentage: Int = 0
    @Published var answerStreak: Int = 0
    @Published var activeAnswer: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func fetchDailyQuestion() {
        // Retrieve the userId from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: User ID not found in UserDefaults")
            return
        }

        // Prepare query parameters
        let dailyQuestionsQueryParams = ["userId": userId, "Date": Time.getPacificDateFormatted()]

        // Make the network request
        NetworkService.shared.request(endpoint: .questions, method: "GET", queryParams: dailyQuestionsQueryParams) { [weak self] (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    // Parse and assign the question from the response
                    if let question = json["Question"] as? String {
                        self?.dailyQuestion = question
                    } else {
                        self?.dailyQuestion = "New Question Coming Soon"
                    }
                case .failure(let error):
                    // Handle error and assign default message
                    self?.dailyQuestion = "New Question Coming Soon"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }


    func fetchYesterdaysQuestion() {
        let previousDailyQuestionsQueryParams = ["Date": Time.getPreviousDateFormatted()]
        NetworkService.shared.request(endpoint: .questionsAnswers, method: "GET", queryParams: previousDailyQuestionsQueryParams) { [weak self] (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let question = json["Question"] as? String,
                       let truePercentage = json["TruePercentage"] as? Double,
                       let falsePercentage = json["FalsePercentage"] as? Double {
                        self?.yesterdaysQuestion = question
                        self?.truePercentage = Int(truePercentage)
                        self?.falsePercentage = Int(falsePercentage)
                    } else {
                        self?.yesterdaysQuestion = "No Question Available"
                    }
                case .failure(let error):
                    self?.yesterdaysQuestion = "No Question Results Available"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchQuestionStreak() {
        // Retrieve the userId from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: User ID not found in UserDefaults")
            return
        }

        // Prepare query parameters
        let answerStreakQueryParams = ["userId": userId]

        // Make the network request
        NetworkService.shared.request(endpoint: .streaksAnswers, method: "GET", queryParams: answerStreakQueryParams) { [weak self] (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    // Parse and assign the streak count from the response
                    if let streaks = json["streak_count"] as? Int {
                        self?.answerStreak = streaks
                    }
                case .failure(let error):
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

}
