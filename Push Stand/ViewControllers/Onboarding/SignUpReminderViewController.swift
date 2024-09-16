import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpReminderViewController: UIViewController {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    let usersEndpoint = "https://qik82nqrt0.execute-api.us-east-1.amazonaws.com/prod/users"
    var dataManager = OnboardingManager.shared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        // Style the time picker
        timePicker.backgroundColor = .black
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.setValue(UIColor.white, forKey: "textColor")
            timePicker.overrideUserInterfaceStyle = .dark
        }
    }
    
    @IBAction func next(_ sender: Any) {
        let utcTime = convertToUTCTime(date: timePicker.date)
        dataManager.onboardingData.reminderTime = utcTime
        createUser()
    }
    
    private func convertToUTCTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter time zone to UTC
        return formatter.string(from: date)
    }
    
    func createUser() {
        guard let email = dataManager.onboardingData.email,
              let password = dataManager.onboardingData.password else {
            print("Email or password not provided")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            self.saveUserDataToFirestore()
        }
    }
    
    private func saveUserDataToFirestore() {
        guard let user = Auth.auth().currentUser else {
            print("Failed to get authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        print("Firebase App: \(FirebaseApp.app()!)")
        print("Firestore Instance: \(Firestore.firestore())")
        let userData: [String: Any] = [
            "UserId": user.uid,
            "Email": user.email ?? "",
            "ReminderTime": dataManager.onboardingData.reminderTime ?? "",
            "Birthdate": formattedDate(date: dataManager.onboardingData.birthday),
            "PhoneNumber": dataManager.onboardingData.phoneNumber ?? ""
        ]
        
        
        NetworkService.shared.request(endpoint: .updateUser, method: "POST", data: userData) { [self] result in
            switch result {
            case .success(let json):
                var currentUser = CurrentUser.shared
                currentUser.uid = user.uid
                currentUser.reminderTime = self.dataManager.onboardingData.reminderTime ?? ""
                currentUser.birthdate = formattedDate(date: self.dataManager.onboardingData.birthday)
                currentUser.phoneNumber = self.dataManager.onboardingData.phoneNumber ?? ""
                currentUser.email = user.email
                currentUser.firebaseAuthToken = ""
                UserDefaults.standard.set(true, forKey: "usersignedin")
                UserDefaults.standard.set(currentUser.uid, forKey: "userId")
                UserDefaults.standard.set(currentUser.email, forKey: "userEmail")
                UserDefaults.standard.synchronize()
                appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
                self.transitionToMainApp()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
    }
    
    private func formattedDate(date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func transitionToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController else { return }
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
