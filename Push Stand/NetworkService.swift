import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = Configuration.shared.baseURL
    
    // Enum to define endpoints
    enum Endpoint: String {
        case home = "/home"
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
    ///   - queryParams: A dictionary containing query parameters to be appended to the URL.
    ///   - data: A dictionary containing data to be serialized into JSON and sent in the request body.
    ///   - completion: A completion handler with a result that either contains a decoded object or an error.
    func request(endpoint: Endpoint, method: String = "GET", queryParams: [String: String]? = nil, data: [String: Any]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.rawValue), resolvingAgainstBaseURL: false)
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let requestURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
