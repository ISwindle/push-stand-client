//
//  LandingRootViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/5/23.
//
import UIKit

class LandingRootViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var joinNowButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        //standLabel.alpha = 0
        //standLabel.textColor = .white
        joinNowButton.alpha = 0
        joinNowButton.setTitle("Join Now", for: .normal)
        joinNowButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        UIView.animate(withDuration: 1.0, animations: {
            // First animation
            //self.pushLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                // Second animation
                //self.standLabel.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
                    // Second animation
                    self.joinNowButton.alpha = 1
                }, completion: nil)
            }
        }}
    
    @IBAction func joinNow(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpInitialPhoneViewController") as! SignUpInitialPhoneViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBAction func learnMore(_ sender: Any) {
        performSegue(withIdentifier: "learnMoreSegue", sender: self)
    }
    @IBAction func login(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
