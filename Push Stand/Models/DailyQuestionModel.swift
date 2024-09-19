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
        let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!, "Date": Time.getPacificDateFormatted()]
        NetworkService.shared.request(endpoint: .questions, method: "GET", queryParams: dailyQuestionsQueryParams) { [weak self] (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let question = json["Question"] as? String {
                        self?.dailyQuestion = question
                    } else {
                        self?.dailyQuestion = "New Question Coming Soon"
                    }
                case .failure(let error):
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
        let answerStreakQueryParams = ["userId": CurrentUser.shared.uid!]
        NetworkService.shared.request(endpoint: .streaksAnswers, method: "GET", queryParams: answerStreakQueryParams) { [weak self] (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let streaks = json["streak_count"] as? Int {
                        self?.answerStreak = streaks
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
