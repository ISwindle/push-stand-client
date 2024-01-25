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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
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
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "joinToPhone", sender: self)
    }
    
    @IBAction func login(_ sender: Any) {
        self.performSegue(withIdentifier: "signIn", sender: self)
    }
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "joinToPhone" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignUpInitialPhoneViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
    
}
