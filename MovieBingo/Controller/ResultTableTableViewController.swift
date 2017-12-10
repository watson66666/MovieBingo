//
//  ResultTableTableViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/11/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase

class ResultTableTableViewController: UITableViewController {

    var age : Int?
    var radius : Int?
    var resultUsers : [User]?
    var selectedUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configure(age:Int, radius: Int, resultUsers: [User]) {
        self.age = age
        self.radius = radius
        self.resultUsers = resultUsers
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultUsers!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
        let user = resultUsers![indexPath.row]
        // Configure the cell
        cell.resultUserName.text = user.name
        
        let imgURL = URL(string: user.imageFileURL)
        let task = URLSession.shared.dataTask(with: imgURL!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.sync() {
                cell.resultUserImage.image = UIImage(data: data)
            }
        }
        task.resume()
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ChatSegue":
            let chatViewController = segue.destination as? ChatViewController
            
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? UITableViewCell {
                let selectedIndex = tableView.indexPath(for: cell)
                if let resultUsers = resultUsers,let selectedIndex = selectedIndex{
                    selectedUser = resultUsers[selectedIndex.row]
                }
                chatViewController?.configure(selectedUser: selectedUser!)
            }
            
        default:
            assert(false, "Unhandled Segue")
        }
    }
}
