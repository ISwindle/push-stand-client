import UIKit

extension UITabBarController {
    func replaceViewController(atIndex index: Int, withViewControllerIdentifier identifier: String) {
        guard index < self.viewControllers?.count ?? 0 else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
        let newViewController = storyboard.instantiateViewController(withIdentifier: identifier)

            // Create a fade animation
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade

            // Replace the view controller at the specified index
            var viewControllers = self.viewControllers
            viewControllers?[index] = newViewController

            // Apply the transition
            self.view.layer.add(transition, forKey: nil)
            self.setViewControllers(viewControllers, animated: false)
        
    }
}
