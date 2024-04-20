//
//  AccountSettingsViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 3/2/24.
//

import UIKit

class AccountSettingsViewController: UIViewController {
    
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var reminderTimePicker: UIDatePicker!
    
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginNavController = storyboard.instantiateViewController(identifier: "InitialViewController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    @IBAction func updateAccount(_ sender: Any) {
        updateSettings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButton.isHidden = true
        birthdatePicker.addTarget(self, action: #selector(birthdatePickerValueChanged(_:)), for: .valueChanged)
        reminderTimePicker.addTarget(self, action: #selector(reminderTimeValueChanged(_:)), for: .valueChanged)
        let semaphore = DispatchSemaphore(value: 0)
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users?userId=\(userId)")
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { semaphore.signal() } // Signal to the semaphore upon task completion
                guard let data = data, error == nil else {
                    print("Error during the network request: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Assign the data to the singleton, ensuring nulls or missing fields default to ""
                        //                        self.currentUser.reminderTime = jsonResponse["ReminderTime"] as? String ?? ""
                        //                        self.currentUser.birthdate = jsonResponse["Birthdate"] as? String ?? ""
                        //                        self.currentUser.phoneNumber = jsonResponse["PhoneNumber"] as? String ?? ""
                        //                        self.currentUser.email = jsonResponse["Email"] as? String ?? ""
                        //                        self.currentUser.firebaseAuthToken = jsonResponse["FirebaseAuthToken"] as? String ?? ""
                        print("Lok!: \(jsonResponse)")
                        DispatchQueue.main.async {
                            if let dateString = jsonResponse["Birthdate"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                
                                if let date = dateFormatter.date(from: dateString) {
                                    self.birthdatePicker.date = date
                                } else {
                                    print("Error: The date string does not match the format expected.")
                                }
                            } else {
                                print("Error: Birthdate key is missing or is not a string.")
                            }
                            // Extract and set the time
                            if let timeString = jsonResponse["ReminderTime"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm:ss"  // Format to match the time string
                                
                                if let time = dateFormatter.date(from: timeString) {
                                    self.reminderTimePicker.date = time
                                } else {
                                    print("Error: The time string does not match the format expected.")
                                }
                            } else {
                                print("Error: Time key is missing or is not a string.")
                            }
                        }
                    }
                } catch {
                    print("Error parsing the JSON response: \(error.localizedDescription)")
                }
            }
            
            task.resume()
            semaphore.wait()
        }
    }
    
    @objc func birthdatePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        // Format the date as needed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        self.updateButton.isHidden = false
        // Now, perform the API call with the selected date
        //performAPICall(withDate: dateString)
    }
    
    @objc func reminderTimeValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        // Format the date as needed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        self.updateButton.isHidden = false
        // Now, perform the API call with the selected date
        //performAPICall(withDate: dateString)
    }
    
    func updateSettings() {
        let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add authorization header if needed
        // request.addValue("Bearer \(yourAuthToken)", forHTTPHeaderField: "Authorization")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentUser = appDelegate.currentUser
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // Example format
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss" // Example format
            
            let payload: [String: Any] = [
                "UserId": currentUser.uid,
                "Birthdate": formatter.string(from: birthdatePicker.date),
                "Email": currentUser.email,
                "PhoneNumber": currentUser.phoneNumber,
                "ReminderTime": timeFormatter.string(from: reminderTimePicker.date),
                "FirebaseAuthToken": currentUser.firebaseAuthToken,
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error encoding JSON: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making PUT request: \(error)")
                    return
                }
                guard let data = data, let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("Server error or invalid response")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response from the server: \(responseString)")
                }
            }
            
            task.resume()
            // Create the alert controller
            let alert = UIAlertController(title: "Update!", message: "Profile Updated Successfully", preferredStyle: .alert)
            
            // Present the alert to the user
            self.present(alert, animated: true, completion: nil)
            
            // Use DispatchQueue to dismiss the alert after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change 2.0 to your desired number of seconds
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
