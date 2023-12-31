
//
import UIKit

class HomeStatsViewController: UIViewController {
    
    @IBOutlet weak var pushStandButton: UIImageView!
    @IBOutlet weak var landingViewWithButton: UIView!
    @IBOutlet weak var pushStandTitle: UIView!
    @IBOutlet var pushStandGesture: UITapGestureRecognizer!
    @IBOutlet weak var standProgressBar: CircularProgressBar!
    @IBOutlet weak var dailyGoalCount: UILabel!
    @IBOutlet weak var globalStandCount: UILabel!
    @IBOutlet weak var onePoint: UILabel!
    
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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the image view can receive touch events
        pushStandButton.isUserInteractionEnabled = true
        

        // Connect the tap gesture recognizer action
        pushStandGesture.addTarget(self, action: #selector(pushStand(_:)))
        pushStandButton.addGestureRecognizer(pushStandGesture)
        
        
        // Example usage
        let dailyGoalsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/dailygoals"
        let dailyGoalsQueryParams = ["date": "2023-12-18"]

        getDailyGoals(endpoint: dailyGoalsEndpoint, queryParams: dailyGoalsQueryParams) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    // Handle successful response with JSON
                    if let goalValue = json["Goal"] as? String {
                        self.dailyGoalCount.text = "\(goalValue)\nDaily Goal"
                    } else {
                        self.dailyGoalCount.text = "0"
                    }
                    if let currentValue = json["Current"] as? String {
                        self.globalStandCount.text = "\(currentValue)"
                    } else {
                        self.globalStandCount.text = "0"
                    }
                    print("JSON: \(json)")
                case .failure(let error):
                    // Handle error
                    self.dailyGoalCount.text = "Error: \(error.localizedDescription)"
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

    }
    
    // Action for tap gesture
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
            segmentedStreakBar.value = 4
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
            segmentedStreakBar.value = 4
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
        self.tabBarController?.tabBar.alpha = 0
    }
    @IBAction func pushStand(_ sender: UITapGestureRecognizer) {
        let uuid = UUID()
        let uuidString = uuid.uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        print(dateString)
        self.tabBarController?.tabBar.isHidden = false
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        let pushStandEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/stand"
        let pushStandQueryParams = ["UserId": uuidString, "Date": dateString]
        postStand(endpoint: pushStandEndpoint, queryParams: pushStandQueryParams) { result in
            DispatchQueue.main.async {
                print("worked")
            }
        }
        UIView.animate(withDuration: 0.15, animations: {
            self.pushStandButton.alpha = 0.0 //this is where daily count will immediately increase by 1
        })  { (true) in
            UIView.animate(withDuration: 0.75, delay: 0.5, animations: {
                //stand streak goes up by 1
            }) { (true) in
                UIView.animate(withDuration: 0.75, delay: 1.25, animations: {
                    self.onePoint.alpha = 1.0
                    //this is where stand streak either does nothing after adding 1 or empties if the stand filled the bar
                    //this is where if bar is filled, point will be "5 Points"
                })  { (true) in
                    UIView.animate(withDuration: 0.75, delay: 2.0, animations: {
                        self.onePoint.alpha = 0.0 //this is where stand streak will increase by 1 as well
                    })  { (true) in
                        UIView.animate(withDuration: 0.0, animations: {
                            self.landingViewWithButton.isHidden = true
                            self.pushStandTitle.isHidden = true
                            self.tabBarController?.tabBar.alpha = 1.0 //why can't I say isHidden = false like the other two?
                        }, completion: { (true) in
                        })
                    }
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
