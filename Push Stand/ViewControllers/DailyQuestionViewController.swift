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
    
    
    @IBOutlet weak var flameSteakImage: UIImageView!
    @IBOutlet weak var streakPointLabel: UILabel!
    @IBOutlet weak var streakSegmentedBar: SegmentedBar!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbsDownAnswer: UIImageView!
    @IBOutlet weak var thumbsUpAnswer: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
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
    
    var answerStreak = 0
    var activeAnswer: Bool = false
    
    
    
    @IBAction func submitAnswer(_ sender: Any) {
        if activeAnswer {
            self.thumbsDownAnswer.image =  UIImage(named: "thumbDownEmpty")
            self.thumbsUpAnswer.image =  UIImage(named: "thumb-up")
        } else {
            self.thumbsDownAnswer.image =  UIImage(named: "thumb-down")
            self.thumbsUpAnswer.image =  UIImage(named: "thumbUpEmpty")
        }
        // Fade in the label
        UIView.animate(withDuration: 1.0, animations: {
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
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": "2"]
        postPoints(endpoint: userPointsEndpoint, queryParams: postPointQueryParams) { result in
            
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.todaysQuestionView.alpha = 0.0
            self.submitButton.alpha = 0.0
        }) { (true) in
            UIView.animate(withDuration: 1.0, animations: {
                self.yesterdaysResultsView.alpha = 1.0
            }) { (true) in

            }
        }
        let previousDailyQuestionsQueryParams = ["Date": getPreviousDateFormatted()]
        // Assuming callAPIGateway is correctly implemented and working
        callAPIGateway(endpoint: dailyQuestionAnswerEndpoint, queryParams: previousDailyQuestionsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    UIView.animate(withDuration: 0.5, animations: {
                        // Handle successful response with JSON
                        if let question = json["Question"] as? String,
                           let truePercentage = json["TruePercentage"] as? Int,
                           let falsePercentage = json["FalsePercentage"] as? Int {
                            // Format the true and false percentages as strings
                            let truePercentageString = String(truePercentage)
                            let falsePercentageString = String(falsePercentage)
                            // Update the label to display the question and percentages
                            self.yesterdayQuestionLabel.text = "\(question)"
                            self.downPercentage.text = "\(falsePercentageString)%"
                            self.upPercentage.text = "\(truePercentageString)%"
                        } else {
                            self.yesterdayQuestionLabel.text = "No Question Available"
                        }
                    }) { (true) in

                    }
                case .failure(let error):
                    // Handle error
                    self.yesterdayQuestionLabel.text = "No Question Results Available"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isUserInteractionEnabled = false
        submitButton.isHidden = true
        thumbsDownAnswer.alpha = 0.0
        thumbsDownAnswer.isUserInteractionEnabled = false
        thumbsUpAnswer.alpha = 0.0
        upPercentage.text = ""
        downPercentage.text = ""
        yesterdayQuestionLabel.text = ""
        thumbsUpAnswer.isUserInteractionEnabled = false
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        yesterdaysResultsView.addGestureRecognizer(tapGesture)
        
        streakSegmentedBar.selectedColor = .cyan
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
                        self.streakSegmentedBar.value = self.answerStreak
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
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let question = json["Question"] as? String {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.questionLabel.text = "\(question)"
                            self.todaysQuestionView.alpha = 1.0
                            self.submitButton.alpha = 1.0
                            self.thumbsUpAnswer.alpha = 1.0
                            self.thumbsDownAnswer.alpha = 1.0
                        }) { (true) in

                        }
                    } else {
                        self.questionLabel.text = "New Question Coming Soon"
                    }
                    if let answer = json["UserAnswer"] as? String {
                        if answer == "" {
                            self.submitButton.isHidden = false
                            self.thumbsDownAnswer.isUserInteractionEnabled = true
                            self.thumbsUpAnswer.isUserInteractionEnabled = true
                            return
                        }
                        self.yesterdaysResultsView.alpha = 1.0
                        // Assuming callAPIGateway is correctly implemented and working
                        self.callAPIGateway(endpoint: self.dailyQuestionAnswerEndpoint, queryParams: previousDailyQuestionsQueryParams, httpMethod: .get) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let json):
                                    print(json)
                                    UIView.animate(withDuration: 0.5, animations: {
                                        // Handle successful response with JSON
                                        if let question = json["Question"] as? String,
                                           let truePercentage = json["TruePercentage"] as? Int,
                                           let falsePercentage = json["FalsePercentage"] as? Int {
                                            // Format the true and false percentages as strings
                                            let truePercentageString = String(truePercentage)
                                            let falsePercentageString = String(falsePercentage)
                                            // Update the label to display the question and percentages
                                            self.yesterdayQuestionLabel.text = "\(question)"
                                            self.downPercentage.text = "\(falsePercentageString)%"
                                            self.upPercentage.text = "\(truePercentageString)%"
                                        } else {
                                            self.yesterdayQuestionLabel.text = "No Question Available"
                                        }
                                    }) { (true) in

                                    }
                                case .failure(let error):
                                    // Handle error
                                    self.yesterdayQuestionLabel.text = "No Question Results Available"
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                case .failure(let error):
                    // Handle error
                    self.questionLabel.text = "New Question Coming Soon"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func thumbsDownTapped() {
        tapHaptic()
        self.thumbsDownAnswer.image =  UIImage(named: "thumb-down")
        self.thumbsUpAnswer.image =  UIImage(named: "thumbUpEmpty")
        self.submitButton.isUserInteractionEnabled = true
        activeAnswer = false
    }
    
    @objc func thumbsUpTapped() {
        tapHaptic()
        self.thumbsDownAnswer.image =  UIImage(named: "thumbDownEmpty")
        self.thumbsUpAnswer.image =  UIImage(named: "thumb-up")
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
            self.streakSegmentedBar.value = self.answerStreak
        }
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
