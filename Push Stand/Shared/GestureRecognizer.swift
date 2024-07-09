//
//  GestureRecognizer.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/7/24.
//

import UIKit

class GestureRecognizer {
    

    static func addTapGestureRecognizer(to view: UIView?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view?.addGestureRecognizer(tapGesture)
    }
    
}
