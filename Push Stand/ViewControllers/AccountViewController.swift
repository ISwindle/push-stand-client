//
//  AccountViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 12/27/23.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginNavController = storyboard.instantiateViewController(identifier: "InitialViewController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    override func viewDidLoad() {
        
    }
    
}
