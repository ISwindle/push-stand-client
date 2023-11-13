import UIKit

class SignUpPhoneViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
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
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "phoneToVerification", sender: self)
    }
    
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "phoneToVerification" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignUpVerificationViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
    
    
}
