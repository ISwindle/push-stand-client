//
//  ContactsViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/3/24.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var contacts: [String] = ["Merica2023", "LMFAO", "John Smith", "Sylvester Stallone", "PeeWee123", "All_Day100", "Bill Russell", "Never_Quit01"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkContactsAuthorizationStatus()
        
        // If using a XIB (nib) file for the cell, uncomment the following line and ensure the nib name matches.
        tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as? ContactsTableViewCell else {
            // Fallback to a default cell if your custom cell cannot be dequeued
            return UITableViewCell()
        }
        let contact = contacts[indexPath.row]
        cell.userNameLabel.text = contact
        
        // Example of conditionally showing/hiding a button in the cell
        // Ensure `multiActionButton` and `isButtonHidden` are implemented in your ContactsTableViewCell
        /*
         if indexPath.row % 2 == 0 {
         cell.multiActionButton.setTitle("Invite", for: .normal)
         cell.multiActionButton.isHidden = false
         } else {
         cell.multiActionButton.setTitle("Added", for: .normal)
         cell.multiActionButton.isHidden = true
         }
         */
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Adjust based on your cell's design
    }
    
    func requestContactAccess() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                print("Failed to request access", error)
                return
            }
            
            if granted {
                print("Access granted")
                // Proceed with accessing contacts
            } else {
                print("Access denied")
                // Handle the case where the user denies access
            }
        }
    }
    
    func checkContactsAuthorizationStatus() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

        switch authorizationStatus {
        case .authorized:
            print("Contacts access has been granted.")
            // Safe to access contacts
        case .denied, .restricted:
            print("Contacts access was denied or restricted.")
            // Guide user to settings or show an appropriate message
            requestContactAccess()
        case .notDetermined:
            print("Contacts access hasn't been requested yet.")
            // Optionally, request access
            requestContactAccess()
        @unknown default:
            fatalError("Unhandled CNAuthorizationStatus case.")
        }
    }
}
