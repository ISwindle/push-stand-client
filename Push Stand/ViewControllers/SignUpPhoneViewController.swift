import UIKit

class SignUpPhoneViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneNumberTextField()
        setupNextButton()
    }
    
    private func setupPhoneNumberTextField() {
        phoneNumberTextField.keyboardType = .numberPad
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberChanged(_:)), for: .editingChanged)
    }
    
    private func setupNextButton() {
        nextButton.isEnabled = false
    }
    
    @objc private func phoneNumberChanged(_ textField: UITextField) {
        guard let text = textField.text else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = isValidPhoneNumber(text)
    }
    
    @IBAction private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction private func next(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text else { return }
        dataManager.onboardingData.phoneNumber = phoneNumber
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpUsernamePasswordViewController") as? SignUpUsernamePasswordViewController else {
            print("ViewController with identifier SignUpUsernamePasswordViewController not found.")
            return
        }
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
