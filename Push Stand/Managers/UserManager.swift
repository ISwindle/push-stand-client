import Foundation
import Combine
import FirebaseMessaging

class UserManager {
    private var currentUser: CurrentUser
    
    init(currentUser: CurrentUser = .shared) {
        self.currentUser = currentUser
    }
    
    func loginUser(with user: User) {
        // Handle login logic, e.g., authenticate with server
        currentUser.update(with: user)
    }
    
    func logoutUser() {
        // Handle logout logic, e.g., clear session, notify server
        currentUser.clear()
    }
    
    func refreshUserDetails() {
        // Fetch and update user details from server
    }
    
    func updateFirebaseToken(userId: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userId.isEmpty else {
            completion(.failure(NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is not available."])))
            return
        }
        
        let queryParams = ["userId": userId]
        NetworkService.shared.request(endpoint: .users, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { result in
            switch result {
            case .success(let jsonResponse):
                let url = URL(string: "https://qik82nqrt0.execute-api.us-east-1.amazonaws.com/prod/users")!
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Include userNumber in the payload
                let payload: [String: Any] = [
                    "UserId": userId,
                    "FirebaseAuthToken": fcmToken,
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                    request.httpBody = jsonData
                } catch {
                    completion(.failure(error))
                    return
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        completion(.failure(NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server error or invalid response."])))
                        return
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response from the server: \(responseString)")
                    }
                    completion(.success(()))
                }
                
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
