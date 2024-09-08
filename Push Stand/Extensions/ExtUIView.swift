//
//  ExtUIView.swift
//  Push Stand
//
//  Created by Isaac Swindle on 9/8/24.
//

import Foundation
import UIKit

protocol DismissableView: UIView {
    var onDismiss: (() -> Void)? { get set }
}
