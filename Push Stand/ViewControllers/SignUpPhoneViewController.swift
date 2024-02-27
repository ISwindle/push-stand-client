import UIKit

class SignUpPhoneViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneNumberTextField()
        // Assuming you have a UITextField instance named myTextField
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberChanged(_:)), for: .editingChanged)
        nextButton.isEnabled = false
    }
    
    private func setupPhoneNumberTextField() {
        // Set up the text field properties
        phoneNumberTextField.keyboardType = .numberPad
        // Add any additional properties or listeners you need
    }
    
    
    
    // If you need to do something when the number is entered,
    // you can add a target to the text field for the editingChanged event
    @objc func phoneNumberChanged(_ textField: UITextField) {
        
        // Assuming nextButton is accessible here, and phoneNumberTextField is your UITextField
            if let text = textField.text, isValidPhoneNumber(text) {
                nextButton.isEnabled = true
            } else {
                nextButton.isEnabled = false
            }
        
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // This pattern matches exactly 10 digits
            let pattern = "^\\d{10,11}$"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: phoneNumber.utf16.count)
            return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    @IBAction func next(_ sender: Any) {
        
        dataManager.onboardingData.phoneNumber = phoneNumberTextField.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpUsernamePasswordViewController") as! SignUpUsernamePasswordViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
