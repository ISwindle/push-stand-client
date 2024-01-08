import UIKit

class ShopViewController: UIViewController {
        
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "usersignedin")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginNavController = storyboard.instantiateViewController(identifier: "LandingRootViewController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
