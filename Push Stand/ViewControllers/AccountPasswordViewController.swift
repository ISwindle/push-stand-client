//
//  AccountPasswordViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 4/9/24.
//

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
    @IBAction func changePassword(_ sender: Any) {
        
        guard let currentUser = Auth.auth().currentUser,
              let currentPassword = currentPassword.text,
              let newPassword = newPassword.text,
              let confirmPassword = confirmNewPassword.text else {
            print("One or more fields are empty.")
            self.showAlert(title: "Error", message: "One or more fields are empty")
            return
        }
                
        // Check if the new passwords match
        guard newPassword == confirmPassword else {
            print("The new passwords do not match.")
            self.showAlert(title: "Password Reset", message: "New password does not match.  Please try again.")
            return
        }
                
                // Re-authenticate the user
                let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: currentPassword)
                currentUser.reauthenticate(with: credential) { authResult, error in
                    if let error = error {
                        print("Re-authentication failed: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Please try again")
                        return
                    }
                    
                    // Proceed to update the password
                    currentUser.updatePassword(to: newPassword) { error in
                        if let error = error {
                            print("Error updating password: \(error.localizedDescription)")
                            self.showAlert(title: "Update Unsuccessful!", message: "Please try again")
                        } else {
                            print("Password updated successfully.")
                            self.showAlert(title: "Update Successful", message: "Your new password has been updated successfully", dismissViewController: true)
                        }
                    }
                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable the submit button initially
        submitButton.isEnabled = false
        
        // Add observers for text field editing changes
        currentPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        newPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmNewPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Check if all three text fields have text
        let currentPasswordText = currentPassword.text ?? ""
        let newPasswordText = newPassword.text ?? ""
        let confirmNewPasswordText = confirmNewPassword.text ?? ""
        let allFieldsFilled = !currentPasswordText.isEmpty && !newPasswordText.isEmpty && !confirmNewPasswordText.isEmpty
        
        // Enable or disable the submit button based on the condition
        submitButton.isEnabled = allFieldsFilled
    }
    
    func showAlert(title: String, message: String, dismissViewController: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if dismissViewController {
                if let navigationController = self.navigationController {
                    // If AccountSettingsViewController is two view controllers back in the navigation stack
                    if let accountSettingsViewController = navigationController.viewControllers.first(where: { $0 is AccountSettingsViewController }) {
                        navigationController.popToViewController(accountSettingsViewController, animated: true)
                    }
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
