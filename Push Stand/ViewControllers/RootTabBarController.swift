//
//  RootTabBarController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/6/23.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQuestionBadge()
    }
    
    func updateQuestionBadge() {
        if let tabBarItems = tabBar.items, tabBarItems.count > 1 {
            let tabBarItem = tabBarItems[1]
            tabBarItem.badgeValue = nil
            if !UserDefaults.standard.bool(forKey: "question-" + getDateFormatted())  {
                tabBarItem.badgeValue = ""
            }
        }
    }
}
