//
//  GroupRequestsViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/3/24.
//
import UIKit

class GroupRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        // If your cell is designed in a XIB file
        let nib = UINib(nibName: "GroupRequestTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GroupRequestTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Adjust based on your data source
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupRequestTableViewCell", for: indexPath) as? GroupRequestTableViewCell else {
            return UITableViewCell()
        }
        
        cell.userNameLabel.text = "Isaac" // Ensure this IBOutlet is connected in your XIB file
        
        // Additional cell configuration goes here
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Adjust as needed
    }
}
