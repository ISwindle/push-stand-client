import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpReminderViewController: UIViewController {
    
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    let usersEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataManager = OnboardingManager.shared
    
    func create() {
        Auth.auth().createUser(withEmail: "user@example.com", password: "password") { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully")
                // Optionally handle authResult.user
            }
        }

    }
    
    func createUser() {
        // Access aggregated data from the data manager
        //let userData = dataManager.onboardingData
        
        // Create a new UUID
        let uuid = UUID()
        
        // Convert UUID to String
        let appId = uuid.uuidString
        
        
        // Reference to Firestore
        let db = Firestore.firestore()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Example format
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss" // Example format
        
        // Data to save
        let userData: [String: String] = [
            "UserId": appId,
            "Email": dataManager.onboardingData.email!,
            "ReminderTime": timeFormatter.string(from: dataManager.onboardingData.reminderTime!),
            "Birthdate": formatter.string(from: dataManager.onboardingData.birthday!),
        ]
        
        print(dataManager.onboardingData)
        // Create the user
        Auth.auth().createUser(withEmail: dataManager.onboardingData.email!, password: dataManager.onboardingData.password!) { result, err in
            
            // Check for errors
            print(err?.localizedDescription)
            if err != nil {
                // There was an error creating the user
                print(err as Any)
                print("ERROR Creating User")
            } else {
                // User was created successfully, now store the first name and last name
                let db = Firestore.firestore()
                let email = self.dataManager.onboardingData.phoneNumber
                let mobileNumber = self.dataManager.onboardingData.phoneNumber
                print("Trying to create document")
                
                
                self.postAPIGateway(endpoint: self.usersEndpoint, postData: userData) {result in
                    print(result)
                }
                
                self.appDelegate.currentUser.email = Auth.auth().currentUser?.email
                self.appDelegate.currentUser.uid = Auth.auth().currentUser?.uid
                UserDefaults.standard.set(true, forKey: "usersignedin")
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userId")
                UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "userEmail")
                UserDefaults.standard.synchronize()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController else { return }
                
                if #available(iOS 15, *) {
                    // iOS 15 and later: Use UIWindowScene.windows
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        setRootViewController(window: window, with: tabBarController)
                    }
                } else {
                    // Earlier iOS versions: Use UIApplication.shared.windows
                    if let window = UIApplication.shared.windows.first {
                        setRootViewController(window: window, with: tabBarController)
                    }
                }
                
                func setRootViewController(window: UIWindow, with viewController: UIViewController) {
                    window.rootViewController = viewController
                    window.makeKeyAndVisible()
                    
                    // Optional: Add a transition animation
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color of the date picker to black
        timePicker.backgroundColor = .black
        
        // Set the tintColor to white to affect non-text components
        timePicker.tintColor = .white
        
        // Attempt to set the text color of the wheels to white
        // This uses a private API and may not work in all versions of iOS
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.setValue(UIColor.white, forKey: "textColor")
            timePicker.overrideUserInterfaceStyle = .dark // This ensures dark mode styling, which may help with your color scheme
        }
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        dataManager.onboardingData.reminderTime = timePicker.date
        createUser()
    }
    
}
