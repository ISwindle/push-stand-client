import UIKit

class SignupBirthdateViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ageConfirmationSwitch: UISwitch!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupTargets()
    }
    
    // MARK: - UI Configuration
    
    /// Configures the initial UI elements such as the date picker and next button.
    private func configureUI() {
        // Disable the "Next" button initially
        nextButton.isEnabled = false
        
        // Set the maximum date for the date picker to today (prevent future dates)
        datePicker.maximumDate = Date()
        
        // Configure the date picker's appearance
        datePicker.backgroundColor = .black
        datePicker.tintColor = .white
        
        // Set date picker style and ensure dark mode compatibility (iOS 13.4+)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.setValue(UIColor.white, forKey: "textColor")
            datePicker.overrideUserInterfaceStyle = .dark
        }
    }
    
    // MARK: - Setup Targets
    
    /// Adds target actions for the age confirmation switch and date picker.
    private func setupTargets() {
        // Listen for value changes in the age confirmation switch
        ageConfirmationSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        
        // Listen for value changes in the date picker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    /// Handles changes in the age confirmation switch.
    @objc private func switchValueDidChange(_ sender: UISwitch) {
        validateAgeAndSwitchState()
    }
    
    /// Handles changes in the date picker.
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        validateAgeAndSwitchState()
    }
    
    /// Validates the selected birthdate and the state of the age confirmation switch.
    private func validateAgeAndSwitchState() {
        // Calculate the user's age
        let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year ?? 0
        let isAgeValid = age >= 18
        
        // Update the switch and button states based on age
        ageConfirmationSwitch.isEnabled = isAgeValid
        ageConfirmationSwitch.isOn = isAgeValid && ageConfirmationSwitch.isOn
        nextButton.isEnabled = isAgeValid && ageConfirmationSwitch.isOn
        
        // Show alert if age is invalid
        if !isAgeValid {
            showAlert(message: "You must be at least 18 years of age to enter")
        }
        
        // Update the age confirmation status in OnboardingData
        OnboardingData.shared.setAgeConfirmed(isAgeValid && ageConfirmationSwitch.isOn)
    }
    
    /// Called when the "Next" button is pressed, proceeding to the next screen if age is confirmed.
    @IBAction private func next(_ sender: Any) {
        // Save the selected birthdate
        OnboardingData.shared.setBirthday(datePicker.date)
        
        // Revalidate the age and switch state before proceeding
        validateAgeAndSwitchState()
        
        // Proceed to the next view controller if age is confirmed
        if OnboardingData.shared.isAgeConfirmed {
            navigateToNextScreen()
        }
    }
    
    // MARK: - Navigation
    
    /// Navigates to the SignUpReminderViewController.
    private func navigateToNextScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpReminderViewController") as? SignUpReminderViewController {
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    // MARK: - Alerts
    
    /// Displays an alert with a specified message.
    /// - Parameter message: The message to display in the alert.
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Important", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
