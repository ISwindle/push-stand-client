import UIKit

class SignupBirthdateViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ageConfirmationSwitch: UISwitch!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupTargets()
    }
    
    private func configureUI() {
        nextButton.isEnabled = false
        datePicker.maximumDate = Date() // Prevents future dates from being selected
        datePicker.backgroundColor = .black
        datePicker.tintColor = .white
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.setValue(UIColor.white, forKey: "textColor")
            datePicker.overrideUserInterfaceStyle = .dark // Ensures dark mode styling
        }
    }
    
    private func setupTargets() {
        ageConfirmationSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        validateAgeAndSwitchState()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        validateAgeAndSwitchState()
    }
    
    private func validateAgeAndSwitchState() {
        let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year ?? 0
        let isAgeValid = age >= 18
        ageConfirmationSwitch.isEnabled = isAgeValid
        ageConfirmationSwitch.isOn = isAgeValid && ageConfirmationSwitch.isOn
        nextButton.isEnabled = isAgeValid && ageConfirmationSwitch.isOn
        dataManager.onboardingData.isAgeConfirmed = isAgeValid && ageConfirmationSwitch.isOn
        
        if !isAgeValid {
            showAlert(message: "You must be at least 18 years of age to enter")
        }
    }
    
    @IBAction func next(_ sender: Any) {
        dataManager.onboardingData.birthday = datePicker.date
        validateAgeAndSwitchState()
        
        if dataManager.onboardingData.isAgeConfirmed {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpReminderViewController") as! SignUpReminderViewController
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Important", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
