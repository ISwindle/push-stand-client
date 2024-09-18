import Foundation
import UIKit

class SignUpInitialPhoneViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var hyperlinkLabel: UILabel!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHyperlinkLabel()
    }
    
    // MARK: - UI Setup
    
    /// Sets up the hyperlink label by making it interactive and underlining specific text.
    private func setupHyperlinkLabel() {
        // Add tap gesture to handle hyperlink clicks
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        hyperlinkLabel.isUserInteractionEnabled = true
        hyperlinkLabel.addGestureRecognizer(tapGesture)
        
        // Underline the desired text in the label
        underlineText(in: hyperlinkLabel, textToUnderline: "Terms of Service")
        underlineText(in: hyperlinkLabel, textToUnderline: "Privacy Policy")
    }
    
    /// Underlines specific text within a UILabel.
    /// - Parameters:
    ///   - label: The UILabel to apply underlining.
    ///   - textToUnderline: The text within the label that should be underlined.
    private func underlineText(in label: UILabel, textToUnderline: String) {
        guard let attributedText = label.attributedText else { return }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let range = (attributedText.string as NSString).range(of: textToUnderline)
        
        // Add underline to the specified range
        if range.location != NSNotFound {
            mutableAttributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            label.attributedText = mutableAttributedText
        }
    }
    
    // MARK: - Gesture Handling
    
    /// Handles taps on the hyperlink label to determine which text was tapped.
    @objc private func labelTapped(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        // Define ranges for the tappable text
        let termsRange = (label.text! as NSString).range(of: "Terms of Service")
        let privacyRange = (label.text! as NSString).range(of: "Privacy Policy")

        // Check if the user tapped on the "Terms of Service" or "Privacy Policy" text
        if sender.didTapAttributedTextInLabel(label: label, inRange: termsRange) {
            navigateToViewController(TermsOfServiceViewController())
        } else if sender.didTapAttributedTextInLabel(label: label, inRange: privacyRange) {
            navigateToViewController(PrivacyPolicyViewController())
        }
    }
    
    // MARK: - Navigation
    
    /// Navigates to a specified view controller by pushing it onto the navigation stack.
    /// - Parameter viewController: The view controller to navigate to.
    private func navigateToViewController(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Actions
    
    /// Handles the sign-in with phone button press and navigates to the phone sign-up view controller.
    @IBAction func signInWithPhone(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPhoneViewController") as? SignUpPhoneViewController {
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
