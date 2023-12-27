
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
    
    @IBOutlet weak var myPointsLabel: UILabel!
    @IBOutlet weak var standStreakIcon: UIImageView!
    @IBOutlet weak var questionStreakIcon: UIImageView!
    @IBOutlet weak var pointsIcon: UIImageView!
    
    @IBOutlet weak var segmentedStreakBar: SegmentedBar!
    @IBOutlet weak var streakImage: UIImageView!
    
    
    
    
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
            myPointsLabel.alpha = 0
            segmentedStreakBar.alpha = 1
            streakImage.alpha = 1
            segmentedStreakBar.selectedColor = .red
            segmentedStreakBar.value = 4
            streakImage.image = UIImage(named: "stand-streak-fire")
        }
    // Action for tap gesture
        @objc func questionStreakTapped() {
            myPointsLabel.alpha = 0
            segmentedStreakBar.alpha = 1
            streakImage.alpha = 1
            segmentedStreakBar.selectedColor = .cyan
            segmentedStreakBar.value = 4
            streakImage.image = UIImage(named: "question-streak-fire")
        }
    // Action for tap gesture
        @objc func pointsTapped() {
            segmentedStreakBar.alpha = 0
            streakImage.alpha = 0
            myPointsLabel.alpha = 1
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
        UIView.animate(withDuration: 1.5, animations: {
            // This will start the animation to fade out the view
            self.landingViewWithButton.alpha = 0
            self.pushStandTitle.alpha = 0
            self.tabBarController?.tabBar.alpha = 1
      
        }) { (finished) in
            // Once the animation is finished, hide the view
            if finished {
                self.landingViewWithButton.isHidden = true
                self.pushStandTitle.isHidden = true
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
