//
//  TestViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 10/30/23.
//

import Foundation
import UIKit

class SignUpInitialPhoneViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signInWithPhone(_ sender: Any) {
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "phoneToPhone", sender: self)
    }
    
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "phoneToPhone" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignUpPhoneViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
    
}
