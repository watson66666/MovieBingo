//
//  LoginViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/5/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Log In"
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
    }

    func getCurrentUser(completionHandler: @escaping (User) -> Void){

        if let currentUser = Auth.auth().currentUser {
            UserService.shared.getUserData { (users) in
                for user in users{
                    if user.name == currentUser.displayName{
                        completionHandler(user)
                    }
                }
            }
        }
    }
    
    @IBAction func login(sender: UIButton) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                let alertController = UIAlertController(title: "Login Error", message: "Both fields must not be blank.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Perform login by calling Firebase APIs
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
            if let currentUser = user {
                UserService.shared.getUserData { (users) in
                    for user in users{
                        if user.name == currentUser.displayName{
                            UserService.shared.currentUser = user
                            UserService.shared.getRecentChatUser()
                        }
                    }
                    
                    if let error = error {
                        let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        return
                    }
                    
                    // Dismiss keyboard
                    self.view.endEditing(true)
                    // Present the main view
                    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
}
