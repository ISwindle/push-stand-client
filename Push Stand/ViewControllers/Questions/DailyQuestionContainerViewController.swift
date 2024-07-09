import UIKit

class DailyQuestionContainerViewController: UIViewController, UITabBarControllerDelegate {
        
    var previousTabIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        self.previousTabIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
            self.performSegue(withIdentifier: "dailyContainerToQuestion", sender: self)
    }
    
    // This method gets called just before the segue starts
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dailyContainerToQuestion" {
            // You can pass data to the destination VC if needed
            if let destinationVC = segue.destination as? DailyQuestionViewController {
                // Set properties on destinationVC here
                //destinationVC.someProperty = "Some Value"
            }
        }
    }
}




    
