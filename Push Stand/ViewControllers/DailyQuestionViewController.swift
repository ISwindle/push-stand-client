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
   
    @IBOutlet weak var answerStackview: UIStackView!
    var answerStreak = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumbsDownAnswer.alpha = 0.0
        thumbsDownAnswer.isUserInteractionEnabled = false
        thumbsUpAnswer.alpha = 0.0
        thumbsUpAnswer.isUserInteractionEnabled = false
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        
        streakSegmentedBar.selectedColor = .cyan
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        let answerStreakQueryParams = ["userId": CurrentUser.shared.uid!]
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
                        self.questionLabel.text = "\(question)"
                        self.thumbsUpAnswer.alpha = 1.0
                        self.thumbsDownAnswer.alpha = 1.0
                    } else {
                        self.questionLabel.text = "New Question Coming Soon"
                    }
                    if let answer = json["UserAnswer"] as? String {
                        if answer == "" {
                            self.thumbsDownAnswer.isUserInteractionEnabled = true
                            self.thumbsUpAnswer.isUserInteractionEnabled = true
                            return
                        }
                        if let isTrue = Bool(answer.lowercased()), isTrue {
                            self.thumbsDownAnswer.isHidden = true
                        } else {
                            self.thumbsUpAnswer.isHidden = true
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
        thumbsUpAnswer.isHidden = true
        let dateString = getDateFormatted()
        let queryParams = [
            "UserId": CurrentUser.shared.uid!,
            "Date": getDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": "false"
        ]
        postAnswer(endpoint: dailyQuestionAnswerEndpoint, queryParams: queryParams) {result in
            print(result)
        }
        
        let unixTimestamp = Date().timeIntervalSince1970
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": "2"]
        postPoints(endpoint: userPointsEndpoint, queryParams: postPointQueryParams) { result in
            DispatchQueue.main.async {
                
            }
        }
    }

    @objc func thumbsUpTapped() {
        tapHaptic()
        thumbsDownAnswer.isHidden = true
        let queryParams = [
            "UserId": CurrentUser.shared.uid!,
            "Date": getDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": "true"
        ]
        let pointQueryParams = [
            "UserId": CurrentUser.shared.uid!,
            "Date": getDateFormatted(),
            "QuestionId": "DEFAULT",
            "Answer": "false"
        ]
        postAnswer(endpoint: dailyQuestionAnswerEndpoint, queryParams: queryParams) {result in
            
        }
        let unixTimestamp = Date().timeIntervalSince1970
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": "2"]
        postPoints(endpoint: userPointsEndpoint, queryParams: postPointQueryParams) { result in
            
        }
        
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
}
