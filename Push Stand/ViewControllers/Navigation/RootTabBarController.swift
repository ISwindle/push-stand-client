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
        updateQuestionBadge()
        observeTabBarItemBadgeCount()
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
    
    private func observeTabBarItemBadgeCount() {
        SessionViewModel.shared.$questionItemBadgeCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newBadgeCount in
                guard let self = self else { return }
                guard let tabBarItems = self.tabBar.items, tabBarItems.count >= self.minimumTabBarItems else {
                    return
                }
                let tabBarItem = tabBarItems[self.questionTabBarIndex]
                tabBarItem.badgeValue = newBadgeCount! > 0 ? "\(newBadgeCount)" : nil
            }
            .store(in: &cancellables)
    }
}
