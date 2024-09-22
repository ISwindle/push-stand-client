//
//  AccountViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 12/27/23.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var standerNumber: UILabel!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        switch indexPath.row {
        case 0:
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
            cell.textLabel?.text = "Settings"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        case 1:
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "terms", for: indexPath)
            cell.textLabel?.text = "Terms of Service"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        case 2:
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "privacy", for: indexPath)
            cell.textLabel?.text = "Privacy Policy"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        case 3:
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "help", for: indexPath)
            cell.textLabel?.text = "Help Center"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        default:
            fatalError("Unexpected indexPath")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the desired height for each cell
        return 55 // You can adjust this value according to your preference
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Optional: Deselect the cell after tap
        
        switch indexPath.row {
        case 0:
            // Example of pushing a view controller that is identified in a storyboard
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "AccountSettingsViewController") as? AccountSettingsViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 1:
                // Present TermsOfServiceViewController
            let webVC = TermsOfServiceViewController()
            present(webVC, animated: true)
        case 2:
                // Present PrivacyPolicyViewController
            let webVC = PrivacyPolicyViewController()
            present(webVC, animated: true)
        case 3:
            // Example of pushing a view controller that is identified in a storyboard
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "HelpCenterViewController") as? HelpCenterViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        default:
            fatalError("Unexpected indexPath")
        }
        
    }
    
    @IBOutlet weak var settingsTableView: UITableView!
    // @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "settings")
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "terms")
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "privacy")
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "help")
        standerNumber.text = " # \(UserDefaults.standard.string(forKey: "userNumber")!)"
    }

    // Action method for xMark button
    @IBAction func xMarkTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
