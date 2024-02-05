import UIKit

class SignupBirthdateViewController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ageConfirmationSwitch: UISwitch!
    
    var dataManager = OnboardingManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the date picker properties if needed
        datePicker.maximumDate = Date() // Prevents future dates from being selected
        
        
        // Set the background color of the date picker to black
        datePicker.backgroundColor = .black
        
        // Set the tintColor to white to affect non-text components
        datePicker.tintColor = .white
        
        // Attempt to set the text color of the wheels to white
        // This uses a private API and may not work in all versions of iOS
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.setValue(UIColor.white, forKey: "textColor")
            datePicker.overrideUserInterfaceStyle = .dark // This ensures dark mode styling, which may help with your color scheme
        }
        
    }
    
    @IBAction func ageConfirmationValueChanged(_ sender: Any) {
        dataManager.onboardingData.isAgeConfirmed = (sender as AnyObject).isOn
    }
    
    @IBAction func next(_ sender: Any) {
        // Save the date and age confirmation in the singleton when the user proceeds to the next step
        dataManager.onboardingData.birthday = datePicker.date
        // Check if the user is at least 18 years old, and update isAgeConfirmed accordingly
        // This is a simplistic check and does not account for leap years etc.
        if let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year, age >= 18 {
            dataManager.onboardingData.isAgeConfirmed = true
        } else {
            dataManager.onboardingData.isAgeConfirmed = false
            // Handle underage users, possibly show an alert
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpReminderViewController") as! SignUpReminderViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}
