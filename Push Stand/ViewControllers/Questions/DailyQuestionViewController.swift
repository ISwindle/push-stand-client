//
//  DailyQuestionViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit
import MessageUI

class DailyQuestionViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Outlets
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
    @IBOutlet weak var shareAskStackView: UIStackView!
    @IBOutlet weak var shareResults: UIButton!
    @IBOutlet weak var askQuestion: UIButton!
    @IBOutlet weak var submitAfterSelection: UIView!
    @IBOutlet weak var bonusAnswerView: UIVisualEffectView!
    @IBOutlet weak var streakFillButton: UIButton!

    
    // MARK: - Properties
    var answerStreak = Defaults.int
    var activeAnswer: Bool = false
    
    // MARK: - Structs
    struct DailyQuestion: Codable {
        let question: String
        let truePercentage: Int
        let falsePercentage: Int
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialView()
        selectQuestionView()
        fetchQuestionStreak()
    }
    
    // MARK: - Setup Methods
    private func setupInitialView() {
        resetUI()
        questionLoadingView.alpha = Constants.fullAlpha
        questionLoadingView.isHidden = false
    }
    
    private func setupGestureRecognizers() {
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        questionBot.addGestureRecognizer(tapGesture)
        
        let shareGesture = UITapGestureRecognizer(target: self, action: #selector(shareResultsTapped))
        shareResults.addGestureRecognizer(shareGesture)
        
        let askGesture = UITapGestureRecognizer(target: self, action: #selector(askQuestionTapped))
        askQuestion.addGestureRecognizer(askGesture)
              
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
    
    // MARK: - Fetch Methods
    private func fetchQuestionStreak() {
        guard let userId =  UserDefaults.standard.string(forKey: "userId") else {
            print("Error: User ID is nil")
            return
        }

        let queryParams = [Constants.UserDefaultsKeys.userId: userId]
        fetchStreakData(with: queryParams) { result in
            DispatchQueue.main.async {
                self.handleFetchResult(result)
            }
        }
    }

    private func fetchStreakData(with queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        NetworkService.shared.request(endpoint: .streaksAnswers, method: HTTPVerbs.get.rawValue, queryParams: queryParams, completion: completion)
    }

    private func handleFetchResult(_ result: Result<[String: Any], Error>) {
        switch result {
        case .success(let json):
            print(json)
            if let streaks = json["streak_count"] as? Int {
                self.answerStreak = streaks
                self.streakSegmentedBar.value = streaks % 10
            } else {
                print("Error: Invalid response format")
            }
        case .failure(let error):
            print("Error fetching streak: \(error.localizedDescription)")
        }
    }
    
    private func fetchDailyQuestion() {
        let dailyQuestionsQueryParams = [Constants.UserDefaultsKeys.userId:  UserDefaults.standard.string(forKey: "userId")!, "Date": Time.getPacificDateFormatted()]
        NetworkService.shared.request(endpoint: .questions, method: HTTPVerbs.get.rawValue, queryParams: dailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let answer = json["UserAnswer"] as? String,
                       let question = json["Question"] as? String {
                        if !answer.isEmpty {
                            self.fetchYesterdaysQuestion()
                            self.saveQuestionAnswerToUserDefaults(for: Time.getPacificDateFormatted())
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
    }
    
    private func fetchYesterdaysQuestion() {
        let previousDailyQuestionsQueryParams = ["Date": Time.getPacificPreviousDateFormatted()]
        NetworkService.shared.request(endpoint: .questionsAnswers, method: HTTPVerbs.get.rawValue, queryParams: previousDailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let question = json["Question"] as? String,
                       let truePercentage = json["TruePercentage"] as? Double,
                       let falsePercentage = json["FalsePercentage"] as? Double {
                        self.hideLoadingView()
                        let newQuestion = DailyQuestion(question: question, truePercentage: Int(truePercentage), falsePercentage: Int(falsePercentage))
                        self.updateUIWithQuestion(newQuestion)
                        self.appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
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
    
    // MARK: - UI Methods
    private func hideLoadingView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.questionLoadingView.alpha = Constants.zeroAlpha
        }) { _ in
            self.questionLoadingView.isHidden = true
        }
    }
    
    private func setupQuestionLabel(question: String) {
        DispatchQueue.main.async {
            self.hideLoadingView()
            let finalPosition = self.questionLabel.frame.origin
            self.questionLabel.frame.origin.y += 30
            self.thumbsDownAnswer.image = UIImage(named: "nay-unselected")
            self.thumbsUpAnswer.image = UIImage(named: "yea-unselected")
            self.todaysQuestionView.alpha = Constants.fullAlpha
            self.dailyQuestionTitle.alpha = Constants.fullAlpha
            self.questionLabel.text = question
            self.submitButton.isHidden = true
            self.submitButton.alpha = Constants.fullAlpha
            self.thumbsDownAnswer.isUserInteractionEnabled = true
            self.thumbsUpAnswer.isUserInteractionEnabled = true
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut]) {
                self.questionLabel.frame.origin = finalPosition
                self.questionLabel.alpha = Constants.fullAlpha
                self.thumbsDownAnswer.alpha = Constants.fullAlpha
                self.thumbsUpAnswer.alpha = Constants.fullAlpha
            }
        }
    }
    
    private func updateUIWithQuestion(_ question: DailyQuestion) {
        DispatchQueue.main.async {
            
            self.yesterdayQuestionLabel.text = question.question
            self.downPercentage.text = "\(question.falsePercentage)%"
            self.upPercentage.text = "\(question.truePercentage)%"
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseIn]) {
                self.yesterdaysResultsView.alpha = Constants.fullAlpha
                self.yesterdaysResultsTitle.alpha = Constants.fullAlpha
                self.yesterdayQuestionLabel.alpha = Constants.fullAlpha
                self.downPercentage.alpha = Constants.fullAlpha
                self.upPercentage.alpha = Constants.fullAlpha
            }
        }
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
    
    private func cacheQuestion(_ question: DailyQuestion) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        UserDefaults.standard.set(todayString, forKey: "cachedQuestionDate")
        if let encoded = try? JSONEncoder().encode(question) {
            UserDefaults.standard.set(encoded, forKey: "cachedDailyQuestion")
        }
    }
    
    private func selectQuestionView() {
        if UserDefaults.standard.bool(forKey: Constants.questionUserDefaultsKey) {
            showYesterdaysResults()
        } else {
            showDailyQuestion()
        }
    }

    private func showYesterdaysResults() {
        dailyQuestionTitle.alpha = Constants.zeroAlpha
        yesterdaysResultsTitle.alpha = Constants.fullAlpha
        fetchYesterdaysQuestion()
    }

    private func showDailyQuestion() {
        dailyQuestionTitle.alpha = Constants.fullAlpha
        yesterdaysResultsTitle.alpha = Constants.zeroAlpha
        fetchDailyQuestion()
    }
    
    // MARK: - Actions
    @IBAction func submitAnswer(_ sender: Any) {
        if activeAnswer {
            self.thumbsDownAnswer.image = UIImage(named: Constants.Images.nayUnselected)
            self.thumbsUpAnswer.image = UIImage(named: Constants.Images.yeaSelected)
        } else {
            self.thumbsDownAnswer.image = UIImage(named: Constants.Images.naySelected)
            self.thumbsUpAnswer.image = UIImage(named: Constants.Images.yeaUnselected)
        }
        self.answerStreak += 1
        
        UIView.animate(withDuration: 1.0) {
            self.streakSegmentedBar.value = self.answerStreak % Constants.questionStreakMax
            if self.answerStreak > 0 && self.answerStreak % Constants.questionStreakMax == 0 {
                self.streakPointLabel.text = "10 Points"
                self.bonusAnswerView.isHidden = false // Show the bonus answer view
            }
            self.streakPointLabel.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 1.0) {
                self.streakPointLabel.alpha = Constants.zeroAlpha
            }
        }
        
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.isHidden = true
        let queryParams = [
            "UserId":  UserDefaults.standard.string(forKey: "userId")!,
            "Date": Time.getPacificDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": activeAnswer ? "true" : "false"
        ]
        NetworkService.shared.request(endpoint: .questionsAnswers, method: HTTPVerbs.post.rawValue, data: queryParams) { result in
            // Update the UserDefaults value
            UserDefaultsManager.shared.setQuestionAnswered(true)
            
            // Notify the tab bar controller to update the badge
            if let tabBarController = self.tabBarController as? RootTabBarController {
                tabBarController.updateQuestionBadge(addBadge: false)
                
            }
            
        }
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (answerStreak % Constants.questionStreakMax == 0) ? Constants.questionStreakHitPoints : Constants.questionPoints
        let postPointQueryParams = ["UserId": UserDefaults.standard.string(forKey: "userId")!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        NetworkService.shared.request(endpoint: .points, method: HTTPVerbs.post.rawValue, data: postPointQueryParams) { result in
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
        
        // TODO: Add Bonus Answer View
        
        self.saveQuestionAnswerToUserDefaults(for: Time.getPacificDateFormatted())
        self.appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
        fetchYesterdaysQuestion()
    }
    
    @IBAction func acknowledgeStreakFill(_ sender: Any) {
        bonusAnswerView.isHidden = true
        self.streakSegmentedBar.value = 0
    }
    
    private func saveQuestionAnswerToUserDefaults(for dateString: String) {
        UserDefaults.standard.set(true, forKey: "question-" + dateString)
        appDelegate.userDefault.set(true, forKey: "question-" + dateString)
        appDelegate.userDefault.synchronize()
    }
    
    // MARK: - Gesture Recognizer Actions
    @objc func thumbsDownTapped() {
        Haptic.heavyTap()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image = UIImage(named: "nay-selected")
        self.thumbsUpAnswer.image = UIImage(named: "yea-unselected")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = false
    }
    
    @objc func thumbsUpTapped() {
        Haptic.heavyTap()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image = UIImage(named: "nay-unselected")
        self.thumbsUpAnswer.image = UIImage(named: "yea-selected")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = true
    }
    
    @objc func askQuestionTapped() {
        performSegue(withIdentifier: "submitQuestionSegue", sender: self)
    }
    
    // utilized this code from Home Screen share icon logic
    @objc private func shareResultsTapped() {
        if MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments() {
            // Capture the screenshot
            let screenshot = takeScreenshot()
            
            // Create the message compose view controller
            let messageVC = MFMessageComposeViewController()
            messageVC.body = """
            Join me on the app that is amplifying the voices of Standing Americans!
            
            Follow us!
            Insta: pushstand_now
            X: @pushstand_now
            
            https://apps.apple.com/app/6469620853
            """
            
            // Attach the screenshot to the message
            if let screenshotData = screenshot.pngData() {
                messageVC.addAttachmentData(screenshotData, typeIdentifier: "public.data", filename: "screenshot.png")
            }
            
            messageVC.recipients = [] // Add default recipients if needed
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        }
    }
    
    // Screenshot of Yesterday's Results for sharing
    private func takeScreenshot() -> UIImage {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(size: window?.bounds.size ?? CGSize.zero)
        return renderer.image { _ in
            window?.drawHierarchy(in: window?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
    
    // utilized this code from Home Screen share icon logic
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitQuestionSegue" {
            if let destinationVC = segue.destination as? SubmitQuestionViewController {
                // Include Setup for Submit Question
            }
        }
    }
}
