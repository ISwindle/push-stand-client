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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func beginAccountDeletion(_ sender: Any) {
//        if let viewController = storyboard?.instantiateViewController(withIdentifier: "AccountDeletionViewController") as? AccountDeletionViewController {
//            navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
