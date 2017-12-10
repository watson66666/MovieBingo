//
//  ChatTableViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/17/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UserService.shared.recentChatUser?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        cell.textLabel?.text = Array(UserService.shared.recentChatUser!.values)[indexPath.row]
        cell.textLabel?.font = cell.textLabel?.font.withSize(30)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "RecentChatSegue":
            let chatViewController = segue.destination as? ChatViewController
            let selectedIndex = tableView.indexPathForSelectedRow
            let recentChatUser = UserService.shared.recentChatUser
            
            let selectedUser = User(userId: Array(recentChatUser!.keys)[selectedIndex!.row],
                                    name: Array(recentChatUser!.values)[selectedIndex!.row])
            chatViewController?.configure(selectedUser: selectedUser!)
            
        default:
            assert(false, "Unhandled Segue")
        }
    }

}
