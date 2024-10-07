import UIKit
import Firebase
import FirebaseFirestore

class AccountSettingsViewController: UIViewController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var reminderTimePicker: UIDatePicker!
    
    @IBOutlet weak var resetTodayButton: UIButton!
    
    
    @IBAction func logoutAction(_ sender: Any) {
        logout()
    }
    
    @IBAction func updateAccount(_ sender: Any) {
        updateSettings()
    }
    
    private func logout() {
        appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
        // Safely remove all data stored in UserDefaults for the app's bundle identifier
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        do {
                try Auth.auth().signOut()
                print("User signed out")

                // Optionally, inform the backend that the user has signed out
                // This might involve deleting the token associated with the user
                // FirebaseTokenManager.shared.invalidateTokenOnBackend()

                // Clear the local FCM token if necessary
                FirebaseTokenManager.shared.clearToken()
        } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
        }
        
        SessionViewModel.shared.clearStandModel()
        SessionViewModel.shared.clearDailyQuestionModel()
        
        // Dismiss any presented view controllers to ensure a clean state
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        
        // Instantiate the initial view controller (e.g., your login screen)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "InitialViewController")
        
        // Change the root view controller to the login screen
        DispatchQueue.main.async {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(loginNavController)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButton.isHidden = true
        self.resetTodayButton.isHidden = true
        if UserDefaults.standard.string(forKey: "userId")! == "4jEEDwZeNiU53fDdSjnFflnMKdq1" || UserDefaults.standard.string(forKey: "userId")! == "q3Alfwryqjhqut5RC4AZM3Djfn02" || UserDefaults.standard.string(forKey: "userId")! == "ZAHntT382tWDySLY5GuWernZxcD2" || UserDefaults.standard.string(forKey: "userId")! == "aS7kx7c28zVNRoigFPZVZGeImd02" {
            self.resetTodayButton.isHidden = false
        }
        birthdatePicker.addTarget(self, action: #selector(birthdatePickerValueChanged(_:)), for: .valueChanged)
        reminderTimePicker.addTarget(self, action: #selector(reminderTimeValueChanged(_:)), for: .valueChanged)
        
        if let reminderTime = UserDefaults.standard.string(forKey: "reminderTime") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ssZ"  // Update format to include time zone
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")  // Specify UTC time zone
            
            if let utcDate = dateFormatter.date(from: reminderTime) {
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
            print("No reminder time found in UserDefaults")
        }
        
        // Access birthdate from UserDefaults
        if let birthdate = UserDefaults.standard.string(forKey: "birthDate") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            birthdatePicker.date = dateFormatter.date(from: birthdate)!
        } else {
            print("No birthdate found in UserDefaults")
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
        // Calculate the user's age based on the selected birthdate
        let age = Calendar.current.dateComponents([.year], from: birthdatePicker.date, to: Date()).year ?? 0
        let isAgeValid = age >= 18
        
        // Ensure the user is at least 18 years old
        if !isAgeValid {
            showAlert(message: "You must be at least 18 years of age to enter")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Format for the birthdate
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss'Z'" // Format for the reminder time in UTC
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter time zone to UTC
        
        let birthdateString = formatter.string(from: birthdatePicker.date)
        let reminderTimeString = convertToUTCTime(date: reminderTimePicker.date) // Function to convert the date to UTC time string
        
        // Prepare the payload for the network request
        let payload: [String: Any] = [
            "UserId": UserDefaults.standard.string(forKey: "userId") ?? "",
            "Birthdate": birthdateString,
            "ReminderTime": reminderTimeString
        ]
        
        // Make the network request to update the user's settings
        NetworkService.shared.request(endpoint: .users, method: "PUT", data: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let responseString = response["message"] as? String {
                        print("Response from the server: \(responseString)")
                    }
                    
                    // Show success alert
                    self.showUpdateSuccessAlert()
                    
                    // Update the UserDefaults with the new reminderTime and birthDate
                    UserDefaults.standard.set(reminderTimeString, forKey: "reminderTime")
                    UserDefaults.standard.set(birthdateString, forKey: "birthDate")
                    UserDefaults.standard.synchronize() // Ensure the changes are saved
                    
                case .failure(let error):
                    // Handle the failure case
                    print("Error updating account settings: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to update settings. Please try again.")
                }
            }
        }
    }
    
    
    @IBAction func resetToday(_ sender: Any) {
        
        logout()
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
