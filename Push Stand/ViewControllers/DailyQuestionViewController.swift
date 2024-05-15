//
//  DailyQuestionViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class DailyQuestionViewController: UIViewController {
    
    
    let dailyQuestionEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/questions"
    let dailyQuestionAnswerEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/questions/answers"
    let userPointsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/points"
    let currentAnswerStreakEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/streaks/answers"
    
    
    @IBOutlet weak var dailyQuestionTitle: UILabel!
    @IBOutlet weak var yesterdaysResultsTitle: UILabel!
    @IBOutlet weak var flameSteakImage: UIImageView!
    @IBOutlet weak var streakPointLabel: UILabel!
    @IBOutlet weak var streakSegmentedBar: SegmentedBar!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbsDownAnswer: UIImageView!
    @IBOutlet weak var thumbsUpAnswer: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
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
    
    struct DailyQuestion : Codable {
        let question: String
        let truePercentage: Int
        let falsePercentage: Int
    }
    
    func fetchQuestion() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Attempt to retrieve the cached question
        if let cachedQuestionData = UserDefaults.standard.object(forKey: "cachedDailyQuestion") as? Data,
           let cachedQuestion = try? JSONDecoder().decode(DailyQuestion.self, from: cachedQuestionData),
           UserDefaults.standard.string(forKey: "cachedQuestionDate") == todayString {
            // Update UI with cached data
            updateUIWithQuestion(cachedQuestion)
            return
        }
        
        // If not cached, fetch new data
        fetchNewQuestionData()
    }
    
    func updateUIWithQuestion(_ question: DailyQuestion) {
        DispatchQueue.main.async {
            self.yesterdayQuestionLabel.text = question.question
            self.downPercentage.text = "\(question.falsePercentage)%"
            self.upPercentage.text = "\(question.truePercentage)%"
            UIView.animate(withDuration: 1.0, animations: {
                self.yesterdaysResultsTitle.alpha = 1.0
                self.yesterdayQuestionLabel.alpha = 1.0
                self.downPercentage.alpha = 1.0
                self.upPercentage.alpha = 1.0
            })
        }
    }
    
    func fetchNewQuestionData() {
        let previousDailyQuestionsQueryParams = ["Date": getPreviousDateFormatted()]
        callAPIGateway(endpoint: dailyQuestionAnswerEndpoint, queryParams: previousDailyQuestionsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    if let question = json["Question"] as? String,
                       let truePercentage = json["TruePercentage"] as? Double,
                       let falsePercentage = json["FalsePercentage"] as? Double {
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
    
    func cacheQuestion(_ question: DailyQuestion) {
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
            self.thumbsDownAnswer.image =  UIImage(named: "thumbDownEmpty")
            self.thumbsUpAnswer.image =  UIImage(named: "thumb-up")
        } else {
            self.thumbsDownAnswer.image =  UIImage(named: "thumb-down")
            self.thumbsUpAnswer.image =  UIImage(named: "thumbUpEmpty")
        }
        self.answerStreak += 1
        // Fade in the label
        UIView.animate(withDuration: 1.0, animations: {
            if self.answerStreak > 0 && self.answerStreak % 10 == 0 {
                self.streakPointLabel.text = "10 Points"
            }
            self.streakPointLabel.alpha = 1.0 // Make the label fully visible
        }) { (finished) in
            // After the fade-in completes, start the fade-out
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                self.streakPointLabel.alpha = 0.0 // Make the label fully transparent
            }, completion: nil)
        }
        
        self.submitButton.isUserInteractionEnabled = false
        self.submitButton.isHidden = true
        let queryParams = [
            "UserId": CurrentUser.shared.uid!,
            "Date": getDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": activeAnswer ? "true" : "false"
        ]
        postAnswer(endpoint: dailyQuestionAnswerEndpoint, queryParams: queryParams) {result in
            
        }
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (answerStreak % 10 == 0) ? "10" : "2"
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        postPoints(endpoint: userPointsEndpoint, queryParams: postPointQueryParams) { result in
        
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.todaysQuestionView.alpha = 0.0
            self.submitButton.alpha = 0.0
            self.dailyQuestionTitle.alpha = 0.0 //Daily Question Title fading out
            self.tabBarItemBadge.badgeValue = nil //Alert badge fading out
        }) { (true) in
            UIView.animate(withDuration: 1.0, animations: {
                self.yesterdaysResultsView.alpha = 1.0
                self.yesterdaysResultsTitle.alpha = 1.0 //Yesterday's Results fading in
            }) { (true) in
                
            }
        }
        let previousDailyQuestionsQueryParams = ["Date": getPreviousDateFormatted()]
        self.yesterdayQuestionLabel.alpha = 0.0
        self.downPercentage.alpha = 0.0
        self.upPercentage.alpha = 0.0
        // Assuming callAPIGateway is correctly implemented and working
        fetchQuestion()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        questionBot.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        streakSegmentedBar.selectedColor = .systemCyan
        
        let answerStreakQueryParams = ["userId": CurrentUser.shared.uid!]
        let previousDailyQuestionsQueryParams = ["Date": getPreviousDateFormatted()]
        let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!, "Date": getDateFormatted()]
        
        //Question Streak
        callAPIGateway(endpoint: currentAnswerStreakEndpoint, queryParams: answerStreakQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let streaks = json["streak_count"] as? Int {
                        self.answerStreak = streaks
                        self.streakSegmentedBar.value = self.answerStreak % 10
                    }
                case .failure(let error):
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        
        //Question
        callAPIGateway(endpoint: dailyQuestionEndpoint, queryParams: dailyQuestionsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                // Save the final position
                switch result {
                case .success(let json):
                    print(json)
                    if let answer = json["UserAnswer"] as? String {
                        if answer == "" {
                            if let question = json["Question"] as? String {
                                self.setupQuestion(question: question)
                            } else {
                                self.questionLabel.text = "New Question Coming Soon"
                            }
                            return
                        }
                        self.yesterdaysResultsView.alpha = 1.0
                        // Assuming callAPIGateway is correctly implemented and working
                        self.fetchQuestion()
                    }
                case .failure(let error):
                    // Handle error
                    self.questionLabel.text = "New Question Coming Soon"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setupQuestion(question:String) {
        
        DispatchQueue.main.async {
            let thumbsDownPosition = self.thumbsDownAnswer.frame.origin
            let thumbsUpPosition = self.thumbsUpAnswer.frame.origin
            let finalPosition = self.questionLabel.frame.origin
            self.questionLabel.frame.origin.y += 30
            //self.thumbsUpAnswer.frame.origin.y += 10
            //self.thumbsDownAnswer.frame.origin.y += 10
            self.thumbsDownAnswer.image =  UIImage(named: "grey-thumb-down")
            self.thumbsUpAnswer.image =  UIImage(named: "grey-thumb-up")
            self.todaysQuestionView.alpha = 1.0
            self.dailyQuestionTitle.alpha = 1.0
            self.questionLabel.text = "\(question)"
            self.submitButton.isHidden = true
            self.submitButton.alpha = 1.0
            self.thumbsDownAnswer.isUserInteractionEnabled = true
            self.thumbsUpAnswer.isUserInteractionEnabled = true
            UIView.animate(withDuration: 2.0, // Animation duration in seconds
                           delay: 0, // Start the animation immediately
                           options: [.curveEaseOut], // Use ease-out animation curve for a smooth effect
                           animations: {
                // Move the label back to its final position
                self.questionLabel.frame.origin = finalPosition
                // Fade in the label by changing alpha to 1
                self.questionLabel.alpha = 1
                // Fade in the label by changing alpha to 1
                self.thumbsDownAnswer.alpha = 1
                // Fade in the label by changing alpha to 1
                self.thumbsUpAnswer.alpha = 1
                
            }) { (isCompleted) in
                // Animation completion block
                if isCompleted {
                    // Animation has completed
                    // Perform any actions you want to take after the animation completes
                }
            }
            
        }
    }
    
    @objc func thumbsDownTapped() {
        tapHaptic()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image =  UIImage(named: "red-thumb-down")
        self.thumbsUpAnswer.image =  UIImage(named: "grey-thumb-up")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = false
    }
    
    @objc func thumbsUpTapped() {
        tapHaptic()
        self.submitButton.isHidden = false
        self.thumbsDownAnswer.image =  UIImage(named: "grey-thumb-down")
        self.thumbsUpAnswer.image =  UIImage(named: "green-thumb-up")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = true
    }
    
    @objc func handleTap() {
        print("tapped")
        performSegue(withIdentifier: "submitQuestionSegue", sender: self)
    }
    
    func postAnswer(endpoint: String, queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let urlString = endpoint
        let url = NSURL(string: urlString)!
        let paramString = queryParams
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            do {
                if let jsonData = data {
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        //                        self.log.mpUpdate("CLIENT_PUSH_NOTIFICATION", "status", "success")
                    }
                }
            } catch let err as NSError {
                // print(err.debugDescription)
                //                self.log.mpUpdate("CLIENT_PUSH_NOTIFICATION_FAILED", "status", "failed", "error", err.localizedDescription)
            }
        }
        task.resume()
        DispatchQueue.main.async {
            print("Answer")
            self.answerStreak = self.answerStreak + 1
            if self.answerStreak > 0 && self.answerStreak % 10 == 0 {
                self.streakSegmentedBar.value = 10
                self.streakPointLabel.text = "10 Points"
                self.bonusAnswerView.isHidden = false
                self.streakFillView.isHidden = false
            } else {
                self.streakSegmentedBar.value = self.answerStreak % 10
            }
            
        }
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
