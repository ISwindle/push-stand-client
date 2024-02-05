//
//  GroupRequestTableViewCell.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/3/24.
//

import UIKit

class GroupRequestTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBAction func declineAction(_ sender: Any) {
        
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        
    }
    
    // This function is called to hide the buttons
    func hideButtons() {
        buttonView.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awake from nib")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
