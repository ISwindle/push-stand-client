//
//  DailyQuestionViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class DailyQuestionViewController: UIViewController {
        
    
    let dailyQuestionEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/questions"
    let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!]
    
    
    @IBOutlet weak var flameSteakImage: UIImageView!
    @IBOutlet weak var streakPointLabel: UILabel!
    @IBOutlet weak var streakSegmentedBar: SegmentedBar!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbsDownAnswer: UIImageView!
    @IBOutlet weak var thumbsUpAnswer: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumbsDownAnswer.isUserInteractionEnabled = true
        thumbsUpAnswer.isUserInteractionEnabled = true
        let thumbsDownGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsDownTapped))
        thumbsDownAnswer.addGestureRecognizer(thumbsDownGesture)
        let thumbsUpGesture = UITapGestureRecognizer(target: self, action: #selector(thumbsUpTapped))
        thumbsUpAnswer.addGestureRecognizer(thumbsUpGesture)
        
        //Yesterday
        callAPIGateway(endpoint: dailyQuestionEndpoint, queryParams: dailyQuestionsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let question = json["Question"] as? String {
                        self.questionLabel.text = "\(question)"
                    } else {
                        self.questionLabel.text = "New Question Coming Soon"
                    }
                case .failure(let error):
                    // Handle error
                    self.questionLabel.text = "New Question Coming Soon"
                    print("Error: \(error.localizedDescription)")
                }
                print(result)
            }
        }
    }
    
    @objc func thumbsDownTapped() {
        tapHaptic()
        thumbsUpAnswer.isHidden = true
    }

    @objc func thumbsUpTapped() {
        tapHaptic()
        thumbsDownAnswer.isHidden = true
    }
    
}
