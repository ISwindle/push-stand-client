import UIKit

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var requests: UIImageView!
    @IBOutlet weak var searchUsers: UIImageView!
    
    // Sample data
    var users: [User] = [
        User(username: "Alice", points: 120),
        User(username: "Bob", points: 150),
        User(username: "Charlie", points: 100),
        // Add more users as needed
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sort the users by points in descending order
        users.sort { $0.points > $1.points }
        
        setupGestures()
        
        // Register the UITableViewCell class with the table view
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Set the delegate and data source
        tableview.delegate = self
        tableview.dataSource = self
        
        searchUsers.isUserInteractionEnabled = true
        requests.isUserInteractionEnabled = true
        
        
    }
    
    func setupGestures() {
        let searchUsersTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchUsersTapped))
        searchUsers.addGestureRecognizer(searchUsersTapGesture)
        
        let requestsTapGesture = UITapGestureRecognizer(target: self, action: #selector(requestsTapped))
        requests.addGestureRecognizer(requestsTapGesture)
    }
    
    @objc func searchUsersTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func requestsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "GroupRequestsViewController") as! GroupRequestsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    // UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(user.username) - \(user.points) points"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchUsers" {
            // Prepare for the searchUsers segue
            // You can pass data to the destination view controller here
        } else if segue.identifier == "requests" {
            // Prepare for the requests segue
            // You can pass data to the destination view controller here
        }
    }
}


