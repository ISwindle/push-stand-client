
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the image view can receive touch events
        pushStandButton.isUserInteractionEnabled = true
        

        // Connect the tap gesture recognizer action
        pushStandGesture.addTarget(self, action: #selector(pushStand(_:)))
        pushStandButton.addGestureRecognizer(pushStandGesture)
        // Example usage
        let endpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/dailygoals"
        let queryParams = ["date": "2023-12-18"]

        callAPIGateway(endpoint: endpoint, queryParams: queryParams) { result in
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.alpha = 0
    }
    @IBAction func pushStand(_ sender: UITapGestureRecognizer) {
        self.tabBarController?.tabBar.isHidden = false
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


    func callAPIGateway(endpoint: String, queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
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
   

}
