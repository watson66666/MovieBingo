//
//  NearbyProfileViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 12/10/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class NearbyProfileViewController: UIViewController {
    
    @IBOutlet var nearbyImageView: UIImageView!
    @IBOutlet var nearbyNameLabel: UILabel!
    @IBOutlet var nearbySexLabel: UILabel!
    @IBOutlet var nearbyAgeLabel: UILabel!
    
    var selectedUser : User?
    var completionBlock : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        UserService.shared.getUserData { (users) in
            for user in users{
                if user.userId == self.selectedUser?.userId{
                    
                    let imgURL = URL(string: (user.imageFileURL))
                    let task = URLSession.shared.dataTask(with: imgURL!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.sync() {
                            self.nearbyImageView.image = UIImage(data: data)
                        }
                    }
                    task.resume()
                    
                    self.nearbyNameLabel.text = user.name
                    self.nearbySexLabel.text = user.sex
                    self.nearbyAgeLabel.text = String.init(describing: user.age)
                }
            }
        }
    }

    func configure(selectedUser: User) {
        self.selectedUser = selectedUser
    }

    @IBAction func dismissMe(_ sender: Any) {
        if let completionBlock = completionBlock {
            completionBlock()
        }
    }
    
}
