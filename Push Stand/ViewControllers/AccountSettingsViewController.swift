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
                                    if let timeString = jsonResponse["ReminderTime"] as? String {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "HH:mm:ssZ"  // Update format to include time zone
                                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")  // Specify UTC time zone
                                        
                                        if let utcDate = dateFormatter.date(from: timeString) {
                                            // Convert the UTC date to local time zone
                                            dateFormatter.timeZone = TimeZone.current
                                            let localTimeString = dateFormatter.string(from: utcDate)
                                            
                                            // Parse the local time string to update the date picker
                                            if let localTime = dateFormatter.date(from: localTimeString) {
                                                self.reminderTimePicker.date = localTime
                                            } else {
                                                print("Error: The local time string does not match the format expected.")
                                            }
                                        } else {
                                            print("Error: The time string does not match the format expected.")
                                        }
                                    } else {
                                        print("Error: Time key is missing or is not a string.")
                                    }                                }
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
        self.updateButton.isHidden = false
    }
    
    @objc func reminderTimeValueChanged(_ sender: UIDatePicker) {
        self.updateButton.isHidden = false
    }
    
    private func convertToUTCTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter time zone to UTC
        return formatter.string(from: date)
    }
    
    func updateSettings() {
        
        let age = Calendar.current.dateComponents([.year], from: birthdatePicker.date, to: Date()).year ?? 0
        let isAgeValid = age >= 18
        
        if !isAgeValid {
            showAlert(message: "You must be at least 18 years of age to enter")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Format for the birthdate

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss'Z'" // Format for the reminder time in UTC
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter time zone to UTC

        let payload: [String: Any] = [
            "UserId": UserDefaults.standard.string(forKey: "userId") ?? "",
            "Birthdate": formatter.string(from: birthdatePicker.date),
            "Email": UserDefaults.standard.string(forKey: "userEmail") ?? "",
            "PhoneNumber": UserDefaults.standard.string(forKey: "userPhoneNumber") ?? "",
            "ReminderTime": convertToUTCTime(date: reminderTimePicker.date),
            "FirebaseAuthToken": UserDefaults.standard.string(forKey: "userFirebaseAuthToken") ?? ""
        ]
        
        NetworkService.shared.request(endpoint: .updateUser, method: "PUT", data: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let responseString = response["message"] as? String {
                        print("Response from the server: \(responseString)")
                    }
                    self.showUpdateSuccessAlert()
                case .failure(let error):
                    print("Error updating account settings: \(error)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Important", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    private func showUpdateSuccessAlert() {
        let alert = UIAlertController(title: "Update!", message: "Profile Updated Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.updateButton.isHidden = true
        })
        self.present(alert, animated: true)
    }
}
