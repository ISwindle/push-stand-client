//
//  RootTabBarController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/6/23.
//

import UIKit
import Combine

class RootTabBarController: UITabBarController {
    
    private let currentUser = CurrentUser.shared
    private let userDefaults = UserDefaults.standard
    private let questionTabBarIndex = 1
    private let minimumTabBarItems = 2
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RootTabBarController {
    public func updateQuestionBadge(addBadge: Bool) {
        guard let tabBarItems = tabBar.items, tabBarItems.count >= minimumTabBarItems else {
            return
        }
        
        let tabBarItem = tabBarItems[questionTabBarIndex]
        
        
        if addBadge {
            tabBarItem.badgeValue = ""
        } else {
            tabBarItem.badgeValue = nil
        }
    }
}
