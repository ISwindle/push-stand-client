//
//  RootTabBarController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/6/23.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    private let currentUser = CurrentUser.shared
    private let userDefaults = UserDefaults.standard
    private let questionTabBarIndex = 1
    private let minimumTabBarItems = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQuestionBadge()
    }
    
    func updateQuestionBadge() {
        guard let tabBarItems = tabBar.items, tabBarItems.count >= minimumTabBarItems else {
            return
        }
        
        let tabBarItem = tabBarItems[questionTabBarIndex]
        tabBarItem.badgeValue = nil
        
        if let lastAnsweredDate = currentUser.lastQuestionAnsweredDate,
           Time.isDatePriorToToday(lastAnsweredDate) {
            tabBarItem.badgeValue = ""
        }
    }
}
