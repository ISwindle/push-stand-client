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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPhoneViewController") as! SignUpPhoneViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
