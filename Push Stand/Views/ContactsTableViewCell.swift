//
//  ContactsTableViewCell.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/3/24.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    

    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var multiActionButton: UIButton!
    var isButtonHidden: Bool = false {
        didSet {
            multiActionButton.isHidden = isButtonHidden
        }
    }
    
    @IBAction func contactAction(_ sender: Any) {
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
