import UIKit
import Firebase

class AccountDeletionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTextFieldTargets()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private func setupUI() {
        deleteAccountButton.isEnabled = false
    }
    
    private func addTextFieldTargets() {
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapDismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func passwordFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    private func validateForm() {
        guard let password = passwordTextField.text, Validator.isValidPassword(password) else {
            deleteAccountButton.isEnabled = false
            return
        }
        deleteAccountButton.isEnabled = true
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        deleteUser { _ in
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginNavController = storyboard.instantiateViewController(identifier: "InitialViewController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
    }
    
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])))
            return
        }
        
        user.delete { error in
            if let error = error {
                // Re-authenticate the user and then try deleting again if deletion fails
                if let credential = self.getReauthenticationCredential() {
                    user.reauthenticate(with: credential) { result, reauthError in
                        if let reauthError = reauthError {
                            completion(.failure(reauthError))
                        } else {
                            // Re-authentication succeeded, try deleting the user again
                            user.delete { deleteError in
                                if let deleteError = deleteError {
                                    completion(.failure(deleteError))
                                } else {
                                    completion(.success(()))
                                }
                            }
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User re-authentication failed."])))
                }
            } else {
                completion(.success(()))
            }
        }
    }

    // Helper function to get the re-authentication credential
    func getReauthenticationCredential() -> AuthCredential? {
        // You need to provide the appropriate credential for re-authentication
        // For example, if the user signed in with email and password:
        let email = CurrentUser.shared.email!
        let password = passwordTextField.text
        let credential = EmailAuthProvider.credential(withEmail: email, password: password!)
        return credential
    }

}
