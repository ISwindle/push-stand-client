import UIKit

extension UIApplication {
    static var sessionViewModel: SessionViewModel {
        return (UIApplication.shared.delegate as! AppDelegate).sessionViewModel
    }
}
