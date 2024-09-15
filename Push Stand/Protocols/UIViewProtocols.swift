import Foundation
import UIKit

protocol DismissableView: UIView {
    var onDismiss: (() -> Void)? { get set }
}

protocol ShareableView: UIView {
    var onShareNow: (() -> Void)? { get set }
}
