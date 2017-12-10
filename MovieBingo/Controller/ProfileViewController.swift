//
//  ProfileViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/5/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var sexLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Profile"
        
        
        if let currentUser = Auth.auth().currentUser {
            nameLabel.text = "Name:     " + currentUser.displayName!
            
            if let currentUser = UserService.shared.currentUser {
                self.ageLabel.text = "Age:     " + String(currentUser.age)
                self.sexLabel.text = "Sex:     " + currentUser.sex
                
                let imgURL = URL(string: currentUser.imageFileURL)
                let task = URLSession.shared.dataTask(with: imgURL!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.sync() {
                        self.avatarImageView.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
        
    }

    @IBAction func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            let alertController = UIAlertController(title: "Logout Error", message: error.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Present the welcome view
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
