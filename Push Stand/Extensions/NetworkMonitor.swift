import Network
import UIKit

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            if self?.isConnected == false {
                DispatchQueue.main.async {
                    self?.presentNoConnectionVC()
                }
            }
        }
        monitor.start(queue: queue)
    }

    private func presentNoConnectionVC() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let noConnectionVC = NetworkErrorViewController()
        noConnectionVC.modalPresentationStyle = .fullScreen
        rootVC.present(noConnectionVC, animated: true, completion: nil)
    }
}
