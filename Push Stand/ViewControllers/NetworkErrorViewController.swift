//
//  NetworkErrorViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 4/29/24.
//

import UIKit

class NetworkErrorViewController: UIViewController {
    
    
    @IBOutlet weak var buttionView: UIView!
    
    @IBOutlet weak var refreshView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView.isHidden = true
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
