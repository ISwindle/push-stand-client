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

    func updateFirebaseToken(fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUser.uid, !userId.isEmpty else {
            completion(.failure(NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is not available."])))
            return
        }

        let queryParams = ["userId": userId]
        NetworkService.shared.request(endpoint: .users, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { result in
            switch result {
            case .success(let jsonResponse):
                self.currentUser.reminderTime = jsonResponse["ReminderTime"] as? String ?? ""
                self.currentUser.birthdate = jsonResponse["Birthdate"] as? String ?? ""
                self.currentUser.phoneNumber = jsonResponse["PhoneNumber"] as? String ?? ""
                self.currentUser.email = jsonResponse["Email"] as? String ?? ""
                self.currentUser.firebaseAuthToken = jsonResponse["FirebaseAuthToken"] as? String ?? ""

                let url = URL(string: "https://qik82nqrt0.execute-api.us-east-1.amazonaws.com/prod/users")!
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let payload: [String: Any] = [
                    "UserId": self.currentUser.uid ?? "",
                    "Birthdate": self.currentUser.birthdate ?? "",
                    "Email": self.currentUser.email ?? "",
                    "PhoneNumber": self.currentUser.phoneNumber ?? "",
                    "ReminderTime": self.currentUser.reminderTime ?? "",
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
                    guard let data = data, let response = response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
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
