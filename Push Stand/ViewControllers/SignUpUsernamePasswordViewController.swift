import UIKit

class SignUpUsernamePasswordViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func enterUnAndPw(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func next(_ sender: Any) {
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "unpwTobirthdate", sender: self)
    }
    
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "unpwTobirthdate" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignupBirthdateViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
    
}
