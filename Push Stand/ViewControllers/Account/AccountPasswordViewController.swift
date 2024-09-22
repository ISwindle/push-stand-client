import UIKit
import Firebase

class AccountPasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func forgetPassword(_ sender: Any) {
        // Retrieve the email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail"), !email.isEmpty else {
            print("Error: Email field is empty")
            self.showAlert(title: "Enter Email", message: "Please enter your account's email first")
            return
        }
        
        // Send a password reset email
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Handle errors during the reset process
                print("Error sending password reset email: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Password reset email unsuccessful")
            } else {
                // Successfully sent the password reset email
                print("Password reset email sent successfully")
                self.showAlert(title: "Password Reset", message: "If your login exists, we will send a password reset email to \(email)")
            }
        }
    }

    
    
    @IBAction func changePassword(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser,
              let currentPassword = currentPassword.text,
              let newPassword = newPassword.text,
              let confirmPassword = confirmNewPassword.text else {
            showAlert(title: "Error", message: "One or more fields are empty")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Password Reset", message: "New password does not match. Please try again.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: currentPassword)
        currentUser.reauthenticate(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Incorrect Password", message: "The password you entered is incorrect.  Please try again.")
                return
            }
            
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(title: "Update Unsuccessful!", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "Update Successful", message: "Your new password has been updated successfully", dismissViewController: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTextFieldObservers()
    }
    
    private func setupUI() {
        submitButton.isEnabled = false
    }
    
    private func addTextFieldObservers() {
        [currentPassword, newPassword, confirmNewPassword].forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let allFieldsFilled = !(currentPassword.text?.isEmpty ?? true) &&
                              !(newPassword.text?.isEmpty ?? true) &&
                              !(confirmNewPassword.text?.isEmpty ?? true)
        submitButton.isEnabled = allFieldsFilled
    }
    
    private func showAlert(title: String, message: String, dismissViewController: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if dismissViewController, let navigationController = self.navigationController {
                if let accountSettingsViewController = navigationController.viewControllers.first(where: { $0 is AccountSettingsViewController }) {
                    navigationController.popToViewController(accountSettingsViewController, animated: true)
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
