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
    }
    
    @objc func birthdatePickerValueChanged(_ sender: UIDatePicker) {
        self.updateButton.isHidden = false
    }
    
    @objc func reminderTimeValueChanged(_ sender: UIDatePicker) {
        self.updateButton.isHidden = false
    }
    
    func updateSettings() {
        let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

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
            "ReminderTime": timeFormatter.string(from: reminderTimePicker.date),
            "FirebaseAuthToken": UserDefaults.standard.string(forKey: "userFirebaseAuthToken") ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
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
                DispatchQueue.main.async {
                    self.showUpdateSuccessAlert()
                }
            }
        }
        
        task.resume()
    }

    private func showUpdateSuccessAlert() {
        let alert = UIAlertController(title: "Update!", message: "Profile Updated Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.updateButton.isHidden = true
        })
        self.present(alert, animated: true)
    }
}
