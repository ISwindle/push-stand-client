import UIKit
import Foundation

class GestureHandler {
    func addLongPressGesture(to view: UIView, target: Any, action: Selector, minimumPressDuration: TimeInterval = 0.5) {
        let longPressGesture = UILongPressGestureRecognizer(target: target, action: action)
        longPressGesture.minimumPressDuration = minimumPressDuration
        view.addGestureRecognizer(longPressGesture)
    }
    
    func addTapGesture(to view: UIView, target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(tapGesture)
    }
    
    func addSwipeGesture(to view: UIView, target: Any, action: Selector, direction: UISwipeGestureRecognizer.Direction) {
        let swipeGesture = UISwipeGestureRecognizer(target: target, action: action)
        swipeGesture.direction = direction
        view.addGestureRecognizer(swipeGesture)
    }
    
    func addPanGesture(to view: UIView, target: Any, action: Selector) {
        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(panGesture)
    }
    
    func addPinchGesture(to view: UIView, target: Any, action: Selector) {
        let pinchGesture = UIPinchGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(pinchGesture)
    }
    
    func addRotationGesture(to view: UIView, target: Any, action: Selector) {
        let rotationGesture = UIRotationGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(rotationGesture)
    }
}
