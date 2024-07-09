//
//  HelpCenterViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 3/2/24.
//

import UIKit

class HelpCenterViewController: UIViewController {
    
    @IBOutlet weak var accountDeletionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func beginAccountDeletion(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: ViewControllers.accountDeletionViewController) as? AccountDeletionViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
