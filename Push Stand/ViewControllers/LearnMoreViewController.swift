//
//  LearnMoreViewController.swift
//  Push Stand
//
//  Created by Tony Russell on 4/24/24.
//

import UIKit

class LearnMoreViewController: UIViewController {

    @IBOutlet weak var exitIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add tap gesture recognizer to the exit icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitIconTapped))
        exitIcon.isUserInteractionEnabled = true
        exitIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc func exitIconTapped() {
        dismiss(animated: true, completion: nil)
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
