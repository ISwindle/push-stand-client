import UIKit

class LandingRootViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var joinNowButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func joinNow(_ sender: Any) {
        navigateToViewController(withIdentifier: ViewControllers.signUpInitialPhoneViewController)
    }
    
    @IBAction func learnMore(_ sender: Any) {
        performSegue(withIdentifier: Segues.learnMore, sender: self)
    }
    
    @IBAction func login(_ sender: Any) {
        navigateToViewController(withIdentifier: ViewControllers.signInViewController)
    }
    
    private func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
