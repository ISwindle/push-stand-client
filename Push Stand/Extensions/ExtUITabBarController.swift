import UIKit

extension UITabBarController {
    
    func replaceViewController(atIndex index: Int, withViewControllerIdentifier identifier: String, storyboardName: String = "Main") {
        guard let viewControllers = self.viewControllers, index < viewControllers.count else {
            print("Index out of bounds or viewControllers are nil")
            return
        }

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: identifier)

        // Apply the transition animation
        applyFadeTransition()

        // Replace the view controller at the specified index
        var updatedViewControllers = viewControllers
        updatedViewControllers[index] = newViewController

        self.setViewControllers(updatedViewControllers, animated: false)
    }
    
    private func applyFadeTransition() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.view.layer.add(transition, forKey: nil)
    }
}
