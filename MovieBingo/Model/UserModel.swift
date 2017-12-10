//
//  Post.swift
//  MovieBingo
//
//  Created by Watson Li on 11/9/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    // MARK: - Properties
    var userId: String
    var imageFileURL: String
    var name: String
    var age: Int
    var sex: String
    var longtitude: Double
    var latitude: Double
    var favouriteMovies: [String]
    
    // MARK: - Firebase Keys
    enum UserInfoKey {
        static let imageFileURL = "imageFileURL"
        static let name = "name"
        static let age = "age"
        static let sex = "sex"
        static let longtitude = "longtitude"
        static let latitude = "latitude"
        static let favouriteMovies = "favouriteMovies"
    }
    
    // MARK: - Initialization
    init(userId: String, imageFileURL: String, name: String, age: Int, sex: String, longtitude:Double, latitude: Double, favouriteMovies: [String]) {
        self.userId = userId
        self.imageFileURL = imageFileURL
        self.name = name
        self.age = age
        self.sex = sex
        self.longtitude = longtitude
        self.latitude = latitude
        self.favouriteMovies = favouriteMovies
    }
    
    init?(userId: String, userInfo: [String: Any]) {
        guard let imageFileURL = userInfo[UserInfoKey.imageFileURL] as? String,
            let name = userInfo[UserInfoKey.name] as? String,
            let age = userInfo[UserInfoKey.age] as? Int,
            let sex = userInfo[UserInfoKey.sex] as? String,
            let longtitude = userInfo[UserInfoKey.longtitude] as? Double,
            let latitude = userInfo[UserInfoKey.latitude] as? Double,
            let favouriteMovies = userInfo[UserInfoKey.favouriteMovies] as? [String]? ?? []
            else {return nil}
        
        self = User(userId: userId, imageFileURL: imageFileURL, name: name, age: age, sex: sex, longtitude: longtitude, latitude: latitude, favouriteMovies: favouriteMovies)
    }
    
    init?(userId: String, name:String){
        self.userId = userId
        self.imageFileURL = ""
        self.name = name
        self.age = 0
        self.sex = ""
        self.longtitude = 0
        self.latitude = 0
        self.favouriteMovies = []
    }
}

class UserService{
    static let shared: UserService = UserService()
    private init(){}
    var currentUser : User?
    var recentChatUser : [String : String]?
    var recentChatReceiver : [String : String]?
    var favouriteMovie : [String] = []
    
    // MARK: - Firebase Database References
    let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts")
    
    // MARK: - Firebase Storage Reference
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    func upload(image: UIImage, age: Int, sex: String, completionHandler: @escaping () -> Void) {
        
        // Generate a unique ID for the post and prepare the post database reference
        let postDatabaseRef = POST_DB_REF.childByAutoId()
        // Use the unique key as the image name and prepare the storage reference
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(postDatabaseRef.key).jpg")
        // Resize the image
        let scaledImage = image.scale(newWidth: 240.0)
        
        guard let imageData = UIImageJPEGRepresentation(scaledImage, 0.9) else {
            return
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        // Observe the upload status
        uploadTask.observe(.success) { (snapshot) in
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            
            // Add a reference in the database
            if let imageFileURL = snapshot.metadata?.downloadURL()?.absoluteString {
                let post: [String : Any] = [User.UserInfoKey.imageFileURL : imageFileURL,
                                            User.UserInfoKey.age : age,
                                            User.UserInfoKey.name : displayName,
                                            User.UserInfoKey.sex : sex,
                                            User.UserInfoKey.longtitude : 0.0,
                                            User.UserInfoKey.latitude : 0.0,
                                            User.UserInfoKey.favouriteMovies: [""],
                ]
                postDatabaseRef.setValue(post)
            }
            completionHandler()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Uploading... \(percentComplete)% complete")
        }

        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserData(completionHandler: @escaping ([User]) -> Void) {
        POST_DB_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [User] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let userInfo = item.value as? [String: Any] ?? [:]
                if let aUser = User(userId: item.key, userInfo: userInfo) {
                    users.append(aUser)
                }
            }
            completionHandler(users)
        })
    }
    
    func getRecentChatUser(){
        POST_DB_REF.child(currentUser!.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            let fetchedUsers = userInfo["recentChatUsers"] as? [String : String]
            self.recentChatUser = fetchedUsers
        })
    }
    
    func getRecentChatUser(receiverId: String){
        POST_DB_REF.child(receiverId).observeSingleEvent(of: .value, with: { (snapshot) in
            let receiverInfo = snapshot.value as? [String: Any] ?? [:]
            let fetchedUsers = receiverInfo["recentChatUsers"] as? [String : String]
            self.recentChatReceiver = fetchedUsers
        })
    }
    
    func updateFavouriteMovie(){
        POST_DB_REF.child(currentUser!.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            if let fetchedMovies = userInfo["favouriteMovies"] as? [String]{
                self.favouriteMovie = fetchedMovies
            }else{
                self.favouriteMovie = []
            }
        })
    }
    
}
