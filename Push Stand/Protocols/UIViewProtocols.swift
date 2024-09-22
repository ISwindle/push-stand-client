import UIKit
import Foundation

// MARK: - Protocol Definitions

/// A protocol that defines a view which can be dismissed.
/// Conforming views should implement dismissal behavior.
protocol DismissableView: UIView {
    /// Closure to be called when the view should be dismissed.
    var onDismiss: (() -> Void)? { get set }
}

/// A protocol that defines a view which supports sharing functionality.
/// Conforming views should implement sharing behavior.
protocol ShareableView: UIView {
    /// Closure to be called when the share action is triggered.
    var onShareNow: (() -> Void)? { get set }
}
