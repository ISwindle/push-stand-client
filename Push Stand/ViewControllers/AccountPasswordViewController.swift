//
//  AccountPasswordViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 4/9/24.
//

import UIKit

class AccountPasswordViewController: UIViewController {

    
    @IBOutlet weak var currentPassword: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @IBAction func changePassword(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
