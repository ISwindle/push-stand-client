//
//  SweepstakesUnlockViewController.swift
//  Push Stand
//
//  Created by Tony Russell on 7/12/24.
//

import UIKit

class SweepstakesUnlockViewController: UIViewController {

    @IBOutlet weak var exit: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap gesture recognizer to the exit icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitTapped))
        exit.isUserInteractionEnabled = true
        exit.addGestureRecognizer(tapGesture)
    }
    @objc func exitTapped() {
        dismiss(animated: true, completion: nil)
    }

}
