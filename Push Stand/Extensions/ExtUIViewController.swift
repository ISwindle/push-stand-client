//
//  ExtViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 1/20/24.
//

import UIKit

extension UIViewController {
    
    
    func callAPIGateway(endpoint: String, queryParams: [String: String], httpMethod: HTTPMethod, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Construct the URL with query parameters
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
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
    
    func postPoints(endpoint: String, queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {        
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
    
    func postAPIGateway(endpoint: String, postData: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Ensure there is no error for this HTTP response
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            // Ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // Serialize the data / NSData object into Dictionary [String : Any]
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any] {
                    print("Response: \(jsonResponse)")
                } else {
                    print("Invalid JSON structure.")
                }
            } catch {
                print("Serialization error: \(error.localizedDescription)")
            }
        }
        
        // Resume the URLSessionDataTask to start the request
        task.resume()
    }
    
    func tapHaptic() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func getDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
    func getPreviousDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Create a Calendar instance
        let calendar = Calendar.current
        
        // Get the date for one day before today
        if let dayBeforeToday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            let dateString = dateFormatter.string(from: dayBeforeToday)
            return dateString
        } else {
            // Handle the case where the date calculation fails
            return "Error calculating the previous day"
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // This pattern matches exactly 10 digits
            let pattern = "^\\d{10,11}$"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: phoneNumber.utf16.count)
            return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    struct Event: Codable {
        let eventDate: Date
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}
