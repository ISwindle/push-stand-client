import UIKit

class LandingRootViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var joinNowButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        performAnimations()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .black
        joinNowButton.alpha = 0
        joinNowButton.setTitle("Join Now", for: .normal)
        joinNowButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    private func performAnimations() {
        UIView.animate(withDuration: 1.0, animations: {
            // Add first animation here if needed
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                // Add second animation here if needed
            }) { _ in
                self.showJoinNowButton()
            }
        }
    }
    
    private func showJoinNowButton() {
        UIView.animate(withDuration: 1.0, animations: {
            self.joinNowButton.alpha = 1
        })
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
