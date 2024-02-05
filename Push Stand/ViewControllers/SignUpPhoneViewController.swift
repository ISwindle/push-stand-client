import UIKit

class SignUpPhoneViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneNumberTextField()
    }
    
    private func setupPhoneNumberTextField() {
        // Set up the text field properties
        phoneNumberTextField.keyboardType = .numberPad
        // Add any additional properties or listeners you need
    }
    
    // If you need to do something when the number is entered,
    // you can add a target to the text field for the editingChanged event
    @objc func phoneNumberChanged(_ textField: UITextField) {
        // Handle the text change
        print("Phone number entered: \(textField.text ?? "")")
    }
    
    @IBAction func next(_ sender: Any) {
        
        dataManager.onboardingData.phoneNumber = phoneNumberTextField.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpUsernamePasswordViewController") as! SignUpUsernamePasswordViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
