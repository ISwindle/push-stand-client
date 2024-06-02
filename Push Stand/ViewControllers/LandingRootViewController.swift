import UIKit

class LandingRootViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var joinNowButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func joinNow(_ sender: Any) {
        navigateToViewController(withIdentifier: "SignUpInitialPhoneViewController")
    }
    
    @IBAction func learnMore(_ sender: Any) {
        performSegue(withIdentifier: "learnMoreSegue", sender: self)
    }
    
    @IBAction func login(_ sender: Any) {
        navigateToViewController(withIdentifier: "SignInViewController")
    }
    
    private func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController else {
            print("ViewController with identifier \(identifier) not found.")
            return
        }
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
