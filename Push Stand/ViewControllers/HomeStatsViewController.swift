
//
import UIKit

class HomeStatsViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var accountButton: UIImageView!
    @IBOutlet weak var pushStandButton: UIImageView!
    @IBOutlet weak var landingViewWithButton: UIView!
    @IBOutlet weak var landingViewWithPicture: UIView!
    @IBOutlet weak var pushStandTitle: UIView!
    @IBOutlet var pushStandGesture: UITapGestureRecognizer!
    @IBOutlet weak var standProgressBar: CircularProgressBar!
    @IBOutlet weak var dailyGoalCount: UILabel!
    @IBOutlet weak var globalStandCount: UILabel!
    @IBOutlet weak var onePoint: UILabel!
    
    @IBOutlet weak var yesterdayLabel: UILabel!
    @IBOutlet weak var standStreakTitle: UILabel!
    @IBOutlet weak var questionStreakTitle: UILabel!
    @IBOutlet weak var pointsTitle: UILabel!
    @IBOutlet weak var myPointsLabel: UILabel!
    @IBOutlet weak var standStreakIcon: UIImageView!
    @IBOutlet weak var questionStreakIcon: UIImageView!
    @IBOutlet weak var pointsIcon: UIImageView!
    
    @IBOutlet weak var segmentedStreakBar: SegmentedBar!
    @IBOutlet weak var streakImage: UIImageView!
    @IBOutlet weak var leftStarImage: UIImageView!
    @IBOutlet weak var rightStarImage: UIImageView!
    
    
    @IBOutlet weak var myCurrentStreakLabel: UILabel!
    @IBOutlet weak var myTotalStandsLabel: UILabel!
    @IBOutlet weak var usaTotalStandsLabel: UILabel!
    
    var goal:Float = 0.0
    var current:Float = 0.0
    var answerStreak:Int = 0
    var myCurrentStreak = 0
    let totalStands = 0
    let usaTotalStands = 0
    let pointsCount = 0
    
    let dailyGoalsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/dailygoals"
    let currentStandStreakEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/streaks"
    let currentAnswerStreakEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/streaks/answers"
    let userTotalStandsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/stands/user"
    let usTotalStandsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/stands"
    let userPointsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/points"
    let pushStandEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/stand"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the image view can receive touch events
        pushStandButton.isUserInteractionEnabled = true
        
        
        // Connect the tap gesture recognizer action
        pushStandGesture.addTarget(self, action: #selector(pushStand(_:)))
        pushStandButton.addGestureRecognizer(pushStandGesture)
        
        
        // Example usage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let dailyGoalsQueryParams = ["date": dateString]
        var newDateString = dateFormatter.string(from: Date())
        
        // Convert the string to a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Use the Calendar to subtract one day
            if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                // Convert the new Date object back to a string
                newDateString = dateFormatter.string(from: newDate)
                print(newDateString)  // Output will be "2023-12-26"
            }
        }
        let yesterdayQueryParams = ["date": newDateString]
        let userTotalStandsQueryParams = ["userId": CurrentUser.shared.uid!]
        
        
        //Today
        callAPIGateway(endpoint: dailyGoalsEndpoint, queryParams: yesterdayQueryParams, httpMethod: .get ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let currentValue = json["Current"] as? String {
                        self.yesterdayLabel.text = "Yesterday: \(currentValue)"
                    } else {
                        self.yesterdayLabel.text = "N/A"
                    }
                case .failure(let error):
                    // Handle error
                    self.dailyGoalCount.text = "0"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        //Yesterday
        callAPIGateway(endpoint: dailyGoalsEndpoint, queryParams: dailyGoalsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    // Handle successful response with JSON
                    if let goalValue = json["Goal"] as? String {
                        self.dailyGoalCount.text = "\(goalValue)\nDaily Goal"
                    } else {
                        self.dailyGoalCount.text = "0\nDaily Goal"
                    }
                    if let currentValue = json["Current"] as? String {
                        self.globalStandCount.text = "\(currentValue)"
                    } else {
                        self.globalStandCount.text = "0"
                    }
                    self.goal = Float((json["Goal"] as? String)!)!
                    self.current = Float((json["Current"] as? String)!)!
                    let progressAmount = self.current / self.goal
                    self.standProgressBar.progress = CGFloat(progressAmount)
                    print("JSON: \(json)")
                case .failure(let error):
                    // Handle error
                    self.dailyGoalCount.text = "0"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        //Yesterday
        callAPIGateway(endpoint: userTotalStandsEndpoint, queryParams: userTotalStandsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let myStands = json["count"] as? Int {
                        self.myTotalStandsLabel.text = "\(myStands)"
                    } else {
                        self.myTotalStandsLabel.text = "0"
                    }
                case .failure(let error):
                    // Handle error
                    self.myTotalStandsLabel.text = "0"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        //Us Total
        callAPIGateway(endpoint: usTotalStandsEndpoint, queryParams: [:], httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let usStands = json["count"] as? Int {
                        self.usaTotalStandsLabel.text = "\(usStands)"
                    } else {
                        self.usaTotalStandsLabel.text = "0"
                    }
                case .failure(let error):
                    // Handle error
                    self.usaTotalStandsLabel.text = "0"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        
        
        // Ensure the image view can interact with the user
        standStreakIcon.isUserInteractionEnabled = true
        questionStreakIcon.isUserInteractionEnabled = true
        pointsIcon.isUserInteractionEnabled = true
        
        // Create a UITapGestureRecognizer
        let standStreakGesture = UITapGestureRecognizer(target: self, action: #selector(standStreakTapped))
        standStreakIcon.addGestureRecognizer(standStreakGesture)
        let questionStreakGesture = UITapGestureRecognizer(target: self, action: #selector(questionStreakTapped))
        questionStreakIcon.addGestureRecognizer(questionStreakGesture)
        let pointsGesture = UITapGestureRecognizer(target: self, action: #selector(pointsTapped))
        pointsIcon.addGestureRecognizer(pointsGesture)
        let accountsGesture = UITapGestureRecognizer(target: self, action: #selector(accountsTapped))
        accountButton.addGestureRecognizer(accountsGesture)
        
    }
    
    // Action for tap gesture
    @objc func accountsTapped() {
        print("Tapped")
        self.performSegue(withIdentifier: "account", sender: self)
    }
    
    @objc func standStreakTapped() {
        standStreakIcon.image = UIImage(named: "stand-streak-icon-active")
        questionStreakIcon.image = UIImage(named: "question-streak-icon")
        pointsIcon.image = UIImage(named: "points-icon")
        standStreakTitle.textColor = .red
        questionStreakTitle.textColor = .white
        pointsTitle.textColor = .white
        myPointsLabel.alpha = 0
        leftStarImage.alpha = 0
        rightStarImage.alpha = 0
        segmentedStreakBar.alpha = 1
        streakImage.alpha = 1
        segmentedStreakBar.selectedColor = .red
        segmentedStreakBar.value = myCurrentStreak
        streakImage.image = UIImage(named: "stand-streak-fire")
    }
    // Action for tap gesture
    @objc func questionStreakTapped() {
        standStreakIcon.image = UIImage(named: "stand-streak-icon")
        questionStreakIcon.image = UIImage(named: "question-streak-icon-active")
        pointsIcon.image = UIImage(named: "points-icon")
        standStreakTitle.textColor = .white
        questionStreakTitle.textColor = .cyan
        pointsTitle.textColor = .white
        myPointsLabel.alpha = 0
        leftStarImage.alpha = 0
        rightStarImage.alpha = 0
        segmentedStreakBar.alpha = 1
        streakImage.alpha = 1
        segmentedStreakBar.selectedColor = .cyan
        segmentedStreakBar.value = answerStreak
        streakImage.image = UIImage(named: "question-streak-fire")
    }
    // Action for tap gesture
    @objc func pointsTapped() {
        standStreakIcon.image = UIImage(named: "stand-streak-icon")
        questionStreakIcon.image = UIImage(named: "question-streak-icon")
        pointsIcon.image = UIImage(named: "points-icon-active")
        standStreakTitle.textColor = .white
        questionStreakTitle.textColor = .white
        pointsTitle.textColor = .yellow
        segmentedStreakBar.alpha = 0
        streakImage.alpha = 0
        myPointsLabel.alpha = 1
        leftStarImage.alpha = 1
        rightStarImage.alpha = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uuid = UUID()
        let uuidString = uuid.uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        print("Defaults: \(UserDefaults.standard.bool(forKey: dateString)) \(dateString)")
        if UserDefaults.standard.bool(forKey: dateString) {
            self.landingViewWithButton.isHidden = true
            self.pushStandTitle.isHidden = true
            self.landingViewWithPicture.isHidden = true
            self.accountButton.isHidden = false
        } else {
            self.tabBarController?.tabBar.alpha = 0
        }
        let currentStandStreakQueryParams = ["userId": CurrentUser.shared.uid!]
        let answerStreakQueryParams = ["userId": CurrentUser.shared.uid!]
        let userPointsQueryParams = ["userId": CurrentUser.shared.uid!]
        //Stand Streak
        callAPIGateway(endpoint: currentStandStreakEndpoint, queryParams: currentStandStreakQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let streaks = json["streak_count"] as? Int {
                        self.myCurrentStreakLabel.text = "\(streaks)"
                        self.segmentedStreakBar.value = streaks
                        self.myCurrentStreak = streaks
                    } else {
                        self.myCurrentStreakLabel.text = "0"
                    }
                case .failure(let error):
                    // Handle error
                    self.myCurrentStreakLabel.text = "0"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        //Question Streak
        callAPIGateway(endpoint: currentAnswerStreakEndpoint, queryParams: answerStreakQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let streaks = json["streak_count"] as? Int {
                        self.answerStreak = streaks
                    }
                case .failure(let error):
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        //Points
        callAPIGateway(endpoint: userPointsEndpoint, queryParams: userPointsQueryParams, httpMethod: .get) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    print(json)
                    // Handle successful response with JSON
                    if let points = json["TotalPoints"] as? Int {
                        self.myPointsLabel.text = "\(points) Points"
                    } else {
                        self.myPointsLabel.text = "0 Points"
                    }
                case .failure(let error):
                    // Handle error
                    self.myPointsLabel.text = "0 Points"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    @IBAction func pushStand(_ sender: UITapGestureRecognizer) {
        let uuid = UUID()
        let uuidString = uuid.uuidString
        let dateString = getDateFormatted()
        self.tabBarController?.tabBar.isHidden = false
        tapHaptic()
        let pushStandQueryParams = ["UserId": CurrentUser.shared.uid!, "Date": dateString]
        postStand(endpoint: pushStandEndpoint, queryParams: pushStandQueryParams) { result in
            DispatchQueue.main.async {
                
            }
        }
        let unixTimestamp = Date().timeIntervalSince1970
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": "1"]
        postPoints(endpoint: userPointsEndpoint, queryParams: postPointQueryParams) { result in
            DispatchQueue.main.async {
                
            }
        }
        print(dateString)
        UserDefaults.standard.set(true, forKey: dateString)
        self.appDelegate.userDefault.set(true, forKey: dateString)
        self.appDelegate.userDefault.synchronize()
        UIView.animate(withDuration: 0.0, animations: {
            // This will start the animation to fade out the view
            self.pushStandButton.alpha = 0
        }) { (true) in
            UIView.animate(withDuration: 1.0, delay: 1.5, animations: {
                self.landingViewWithPicture.alpha = 0
                self.pushStandTitle.alpha = 0
                self.landingViewWithButton.alpha = 0
                self.tabBarController?.tabBar.alpha = 1
            }) { (finished) in
                // Once the animation is finished, hide the view
                if finished {
                    self.landingViewWithButton.isHidden = true
                    self.pushStandTitle.isHidden = true
                    self.landingViewWithPicture.isHidden = true
                    self.accountButton.isHidden = false
                }
            }
        }
    }
    
    func getDailyGoals(endpoint: String, queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Construct the URL with query parameters
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // URLSession task to call the API
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid data
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Attempt to parse JSON
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
        
        // Start the task
        task.resume()
    }
    
    func postStand(endpoint: String, queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        if let currentCount = Int(self.globalStandCount.text ?? "0") {
            let newCount = currentCount + 1
            self.globalStandCount.text = String(newCount)
        }
        if let currentCount = Int(self.myCurrentStreakLabel.text ?? "0") {
            let newCount = currentCount + 1
            self.myCurrentStreakLabel.text = String(newCount)
        }
        if let currentCount = Int(self.myTotalStandsLabel.text ?? "0") {
            let newCount = currentCount + 1
            self.myTotalStandsLabel.text = String(newCount)
        }
        if let currentCount = Int(self.usaTotalStandsLabel.text ?? "0") {
            let newCount = currentCount + 1
            self.usaTotalStandsLabel.text = String(newCount)
        }
        self.current = self.current + 1
        let progressAmount = self.current / self.goal
        self.standProgressBar.progress = CGFloat(progressAmount)
        self.myCurrentStreak = self.myCurrentStreak + 1
        segmentedStreakBar.value = myCurrentStreak
        let newCount = pointsCount + 1
        self.myPointsLabel.text = "\(newCount) Points"
        
        
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
        
    }
    
    
}
