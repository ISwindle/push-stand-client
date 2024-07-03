//
//  DailyQuestionViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class DailyQuestionViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var dailyQuestionTitle: UILabel!
    @IBOutlet weak var yesterdaysResultsTitle: UILabel!
    @IBOutlet weak var flameSteakImage: UIImageView!
    @IBOutlet weak var streakPointLabel: UILabel!
    @IBOutlet weak var streakSegmentedBar: SegmentedBar!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbsDownAnswer: UIImageView!
    @IBOutlet weak var thumbsUpAnswer: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var questionLoadingView: UIView!
    @IBOutlet weak var tabBarItemBadge: UITabBarItem!
    
    @IBOutlet weak var todaysQuestionView: UIView!
    @IBOutlet weak var yesterdaysResultsView: UIView!
    @IBOutlet weak var yesterdaysQuestion: UIView!
    @IBOutlet weak var yesterdayQuestionLabel: UILabel!
    @IBOutlet weak var answerStackview: UIStackView!
    @IBOutlet weak var downPercentage: UILabel!
    @IBOutlet weak var upPercentage: UILabel!
    @IBOutlet weak var yesterdayThumbsDown: UIImageView!
    @IBOutlet weak var yesterdayThumbsUp: UIImageView!
    @IBOutlet weak var questionBot: UIImageView!
    
    @IBOutlet weak var submitAfterSelection: UIView!
    
    @IBOutlet weak var bonusAnswerView: UIVisualEffectView!
    @IBOutlet weak var streakFillView: UIVisualEffectView!
    @IBOutlet weak var streakFillButton: UIButton!
    
    var answerStreak = 0
    var activeAnswer: Bool = false
    
    struct DailyQuestion: Codable {
        let question: String
        let truePercentage: Int
        let falsePercentage: Int
    }
    
    fileprivate func updateQuestionBadge() {
        if let tabBarController = self.tabBarController {
            // Access the tab bar items
            if let tabBarItems = tabBarController.tabBar.items {
                // Ensure there are enough tab bar items
                if tabBarItems.count > 1 {
                    // Access the tab bar item at the specified index (e.g., index 1)
                    let tabBarItem = tabBarItems[1]
                    
                    // Set a new image for the tab bar item
                    tabBarItem.badgeValue = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        for (key, value) in dictionary {
            print("\(key): \(value)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetUI()
        
        //added so that questionLoadingView always appear first, no blank screen
        //also acts as a way to reiterate why we are answering the question
        self.questionLoadingView.alpha = 1.0
        self.questionLoadingView.isHidden = false
        
        if UserDefaults.standard.bool(forKey: "question-" + getDateFormatted()) {
            self.dailyQuestionTitle.alpha = 0.0
            self.yesterdaysResultsTitle.alpha = 1.0
            fetchYesterdaysQuestion()
        } else {
            self.dailyQuestionTitle.alpha = 1.0
            self.yesterdaysResultsTitle.alpha = 0.0
            fetchDailyQuestion()
        }
        
        fetchQuestionStreak()
        
    }
    
    private func setupGestureRecognizers() {
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        questionBot.addGestureRecognizer(tapGesture)
    }
    
    private func resetUI() {
        questionLabel.alpha = 0.0
        submitButton.isUserInteractionEnabled = false
        submitButton.isHidden = true
        thumbsDownAnswer.alpha = 0.0
        thumbsDownAnswer.isUserInteractionEnabled = false
        thumbsUpAnswer.alpha = 0.0
        upPercentage.text = ""
        downPercentage.text = ""
        yesterdayQuestionLabel.text = ""
        thumbsUpAnswer.isUserInteractionEnabled = false
        streakSegmentedBar.selectedColor = .systemBlue
    }
    
    private func fetchQuestionStreak() {
        let answerStreakQueryParams = ["userId": CurrentUser.shared.uid!]
        NetworkService.shared.request(endpoint: .streaksAnswers, method: "GET", queryParams: answerStreakQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let streaks = json["streak_count"] as? Int {
                        self.answerStreak = streaks
                        self.streakSegmentedBar.value = self.answerStreak % 10
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchDailyQuestion() {
        let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!, "Date": getDateFormatted()]
        print("Question")
        NetworkService.shared.request(endpoint: .questions, method: "GET", queryParams: dailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let answer = json["UserAnswer"] as? String,
                       let question = json["Question"] as? String {
                        print(answer.isEmpty)
                        if !answer.isEmpty {
                            self.fetchYesterdaysQuestion()
                            self.saveQuestionAnswerToUserDefaults(for: self.getDateFormatted())
                            return
                        }
                        self.setupQuestionLabel(question: question)
                    } else {
                        self.questionLabel.text = "New Question Coming Soon"
                    }
                case .failure(let error):
                    self.questionLabel.text = "New Question Coming Soon"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        print("Question After")
    }
    
    private func fetchYesterdaysQuestion() {
        let previousDailyQuestionsQueryParams = ["Date": getPreviousDateFormatted()]
        NetworkService.shared.request(endpoint: .questionsAnswers, method: "GET", queryParams: previousDailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let question = json["Question"] as? String,
                       let truePercentage = json["TruePercentage"] as? Double,
                       let falsePercentage = json["FalsePercentage"] as? Double {
                        self.hideLoadingView()
                        let newQuestion = DailyQuestion(question: question, truePercentage: Int(truePercentage), falsePercentage: Int(falsePercentage))
                        self.updateUIWithQuestion(newQuestion)
                        self.cacheQuestion(newQuestion)
                    } else {
                        self.yesterdayQuestionLabel.text = "No Question Available"
                    }
                case .failure(let error):
                    self.yesterdayQuestionLabel.text = "No Question Results Available"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func hideLoadingView(){
        UIView.animate(withDuration: 0.25, animations: {
            self.questionLoadingView.alpha = 0
        }) { _ in
            self.questionLoadingView.isHidden = true
        }
    }
    
    private func setupQuestionLabel(question: String) {
        DispatchQueue.main.async {
            self.hideLoadingView()
            let finalPosition = self.questionLabel.frame.origin
            self.questionLabel.frame.origin.y += 30
            self.thumbsDownAnswer.image = UIImage(named: "grey-thumb-down")
            self.thumbsUpAnswer.image = UIImage(named: "grey-thumb-up")
            self.todaysQuestionView.alpha = 1.0
            self.dailyQuestionTitle.alpha = 1.0
            self.questionLabel.text = question
            self.submitButton.isHidden = true
            self.submitButton.alpha = 1.0
            self.thumbsDownAnswer.isUserInteractionEnabled = true
            self.thumbsUpAnswer.isUserInteractionEnabled = true
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut]) {
                self.questionLabel.frame.origin = finalPosition
                self.questionLabel.alpha = 1
                self.thumbsDownAnswer.alpha = 1
                self.thumbsUpAnswer.alpha = 1
            }
        }
    }
    
    private func setupQNouestionLabel(question: String) {
        DispatchQueue.main.async {
            let finalPosition = self.questionLabel.frame.origin
            self.questionLabel.frame.origin.y += 30
            self.thumbsDownAnswer.image = UIImage(named: "grey-thumb-down")
            self.thumbsUpAnswer.image = UIImage(named: "grey-thumb-up")
            self.todaysQuestionView.alpha = 1.0
            self.dailyQuestionTitle.alpha = 1.0
            self.questionLabel.text = question
            self.submitButton.isHidden = true
            self.submitButton.alpha = 1.0
            self.thumbsDownAnswer.isUserInteractionEnabled = true
            self.thumbsUpAnswer.isUserInteractionEnabled = true
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut]) {
                self.questionLabel.frame.origin = finalPosition
                self.questionLabel.alpha = 1
                self.thumbsDownAnswer.alpha = 1
                self.thumbsUpAnswer.alpha = 1
            }
        }
    }
    
    private func updateUIWithQuestion(_ question: DailyQuestion) {
        DispatchQueue.main.async {
            self.yesterdaysResultsView.alpha = 1.0
            self.yesterdayQuestionLabel.text = question.question
            self.downPercentage.text = "\(question.falsePercentage)%"
            self.upPercentage.text = "\(question.truePercentage)%"
            UIView.animate(withDuration: 1.0) {
                self.yesterdaysResultsTitle.alpha = 1.0
                self.yesterdayQuestionLabel.alpha = 1.0
                self.downPercentage.alpha = 1.0
                self.upPercentage.alpha = 1.0
            }
        }
    }
    
    private func cacheQuestion(_ question: DailyQuestion) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        UserDefaults.standard.set(todayString, forKey: "cachedQuestionDate")
        if let encoded = try? JSONEncoder().encode(question) {
            UserDefaults.standard.set(encoded, forKey: "cachedDailyQuestion")
        }
    }
    
    @IBAction func submitAnswer(_ sender: Any) {
        if activeAnswer {
            self.thumbsDownAnswer.image = UIImage(named: "thumbDownEmpty")
            self.thumbsUpAnswer.image = UIImage(named: "thumb-up")
        } else {
            self.thumbsDownAnswer.image = UIImage(named: "thumb-down")
            self.thumbsUpAnswer.image = UIImage(named: "thumbUpEmpty")
        }
        self.answerStreak += 1
        
        UIView.animate(withDuration: 1.0) {
            self.streakSegmentedBar.value = self.answerStreak % 10
            if self.answerStreak > 0 && self.answerStreak % 10 == 0 {
                self.streakPointLabel.text = "10 Points"
            }
            self.streakPointLabel.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 1.0) {
                self.streakPointLabel.alpha = 0.0 // Make the label fully transparent
            }
        }
        
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.isHidden = true
        let queryParams = [
            "UserId": CurrentUser.shared.uid!,
            "Date": getDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": activeAnswer ? "true" : "false"
        ]
        NetworkService.shared.request(endpoint: .questionsAnswers, method: "POST", data: queryParams) { result in
            // Update the UserDefaults value
            UserDefaultsManager.shared.setQuestionAnswered(true)
            
            // Notify the tab bar controller to update the badge
            if let tabBarController = self.tabBarController as? RootTabBarController {
                tabBarController.updateQuestionBadge()
            }
        }
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (answerStreak % 10 == 0) ? "10" : "2"
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        NetworkService.shared.request(endpoint: .points, method: "POST", data: postPointQueryParams) { result in
            self.updateQuestionBadge()
        }
        UIView.animate(withDuration: 1.0) {
            self.todaysQuestionView.alpha = 0.0
            self.submitButton.alpha = 0.0
            self.dailyQuestionTitle.alpha = 0.0 // Daily Question Title fading out
            self.tabBarItemBadge.badgeValue = nil // Alert badge fading out
        } completion: { _ in
            UIView.animate(withDuration: 1.0) {
                self.yesterdaysResultsView.alpha = 1.0
                self.yesterdaysResultsTitle.alpha = 1.0 // Yesterday's Results fading in
            }
        }
        self.saveQuestionAnswerToUserDefaults(for: self.getDateFormatted())
        UIApplication.shared.applicationIconBadgeNumber =  UIApplication.shared.applicationIconBadgeNumber - 1
        fetchYesterdaysQuestion()
    }
    
    private func saveQuestionAnswerToUserDefaults(for dateString: String) {
        UserDefaults.standard.set(true, forKey: "question-" + dateString)
        appDelegate.userDefault.set(true, forKey: "question-" + dateString)
        appDelegate.userDefault.synchronize()
    }
    
    @objc func thumbsDownTapped() {
        tapHaptic()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image = UIImage(named: "red-thumb-down")
        self.thumbsUpAnswer.image = UIImage(named: "grey-thumb-up")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = false
    }
    
    @objc func thumbsUpTapped() {
        tapHaptic()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image = UIImage(named: "grey-thumb-down")
        self.thumbsUpAnswer.image = UIImage(named: "green-thumb-up")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = true
    }
    
    @objc func handleTap() {
        performSegue(withIdentifier: "submitQuestionSegue", sender: self)
    }
    
    @IBAction func acknowledgeStreakFill(_ sender: Any) {
        bonusAnswerView.isHidden = true
        streakFillView.isHidden = true
        self.streakSegmentedBar.value = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitQuestionSegue" {
            if let destinationVC = segue.destination as? SubmitQuestionViewController {
                // Pass data to destinationVC
                // destinationVC.someProperty = someValue
            }
        }
    }
}
