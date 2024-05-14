import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop")!
    
    // Enum to define endpoints
    enum Endpoint: String {
        case dailyGoals = "/dailygoals"
        case streaks = "/streaks"
        case streaksAnswers = "/streaks/answers"
        case userStands = "/stands/user"
        case stands = "/stands"
        case points = "/points"
        case stand = "/stand"
        case checkEmail = "/users/checkEmail"
        case questions = "/questions"
        case questionsAnswers = "/questions/answers"
        case questionsSuggestions = "/questions/suggestions"
        case updateUser = "/users"
    }
    
    /// Generic function to make HTTP requests
    /// - Parameters:
    ///   - endpoint: The endpoint to hit relative to the base URL.
    ///   - method: The HTTP method to use (e.g., "GET", "POST").
    ///   - data: A dictionary containing data to be serialized into JSON and sent in the request body.
    ///   - completion: A completion handler with a result that either contains a decoded object or an error.
    func request<T: Decodable>(endpoint: Endpoint, method: String = "GET", data: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        let requestURL = baseURL.appendingPathComponent(endpoint.rawValue)
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept") // Accept JSON responses
        
        if let data = data, ["POST", "PUT"].contains(method) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown network error"])))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// Example models for Decodable types
struct DailyGoal: Decodable {
    let id: String
    let title: String
}

struct UserStreak: Decodable {
    let days: Int
}

// Example usage
// Call this in your ViewController or ViewModel to fetch data
func fetchDailyGoals() {
    NetworkService.shared.request(endpoint: .dailyGoals) { (result: Result<[DailyGoal], Error>) in
        switch result {
        case .success(let goals):
            print("Successfully fetched daily goals:", goals)
        case .failure(let error):
            print("Error fetching daily goals:", error.localizedDescription)
        }
    }
}
