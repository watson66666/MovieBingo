//
//  SignUpViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/5/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var sexSegmentControl: UISegmentedControl!
    @IBOutlet var uploadImageLabel: UILabel!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up"
        nameTextField.becomeFirstResponder()
    }

    @IBAction func registerAccount(sender: UIButton) {
        
        // Validate the input
        guard let name = nameTextField.text, name != "",
            let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "",
            let theAge = ageTextField.text, theAge != "",
            let theSex = sexSegmentControl.titleForSegment(at: sexSegmentControl.selectedSegmentIndex), theSex != "",
            avatarImage != nil
            else {
                
                let alertController = UIAlertController(title: "Registration Error", message: "Please make sure you provide all infomation complete the registration.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        // Register the user account on Firebase
        Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
            
            if let error = error {
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Save the name of the user
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("Failed to change the display name: \(error.localizedDescription)")
                    }
                })
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            UserService.shared.upload(image: self.avatarImage!, age: Int(self.ageTextField.text!)!, sex: self.sexSegmentControl.titleForSegment(at: self.sexSegmentControl.selectedSegmentIndex)!, completionHandler: {
                self.dismiss(animated: true, completion: nil)
            })
            
        })
    }
    
    @IBAction func uploadAvatar(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose an image", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "From photos album", style: .default) { (action:UIAlertAction)  in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true)
            }else{
                let alert = UIAlertController(title: "Photos album not available", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
            
        }
        let action2 = UIAlertAction(title: "Take a new one", style: .default) { (action:UIAlertAction)  in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            }else{
                let alert = UIAlertController(title: "Camera not available", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        self.present(actionSheet, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        avatarImage = selectedImage
        uploadImageLabel.text = "Image selected"
            
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
}
