//
//  BuildUpPointsView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit

class BuildUpPointsView: UIView {

    @IBOutlet var buildUpPointsView: UIVisualEffectView!
    @IBOutlet weak var dismissView: UIButton!
    
    var onDismiss: (() -> Void)?
    
    @IBAction func gotIt(_ sender: Any) {
        onDismiss?()
    }
    
}
