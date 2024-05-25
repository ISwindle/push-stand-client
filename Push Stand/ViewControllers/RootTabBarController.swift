//
//  RootTabBarController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/6/23.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "question-" + getDateFormatted())  {
            updateBadge()
        }
    }
    
    func updateBadge() {
        if let tabBarItems = tabBar.items, tabBarItems.count > 1 {
            let tabBarItem = tabBarItems[1]
            tabBarItem.badgeValue = nil
        }
    }
    
    func scheduleDailyBadgeReset() {
        // Using a Timer for demonstration; in a real app, consider using background fetch or notifications
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            UserDefaultsManager.shared.setQuestionAnswered(false)
            self?.updateBadge()
        }
    }
}
