//
//  SearchViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/11/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    @IBOutlet var ageNumLabel: UILabel!
    @IBOutlet var radiusNumLabel: UILabel!
    var age : Int?
    var radius : Int?
    var resultUsers = [User]()
    var movieName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        age = 18
        radius = 1
        // Do any additional setup after loading the view.
    }
    
    func configure(movieTitle: String) {
        self.movieName = movieTitle
    }
    
    @IBAction func changeAge(_ sender: UISlider) {
        age = Int(sender.value)
        ageNumLabel.text = String(describing: age!)
        findNearby(radius: Double(radius!)){(users) in
            self.resultUsers = users
        }
    }
    
    @IBAction func changeRadius(_ sender: UISlider) {
        radius = Int(sender.value)
        radiusNumLabel.text = String(describing: radius!)
        findNearby(radius: Double(radius!)){(users) in
            self.resultUsers = users
        }
    }
    
    //Calculates the distance on a sphere between two points given in latitude and longitude using the haversine formula.
    func haversineDinstance(la1: Double, lo1: Double, la2: Double, lo2: Double, radius: Double = 6367444.7) -> Double {
        
        let haversin = { (angle: Double) -> Double in
            return (1 - cos(angle))/2
        }
        
        let ahaversin = { (angle: Double) -> Double in
            return 2*asin(sqrt(angle))
        }
        
        // Converts from degrees to radians
        let dToR = { (angle: Double) -> Double in
            return (angle / 360) * 2 * Double.pi
        }
        
        let lat1 = dToR(la1)
        let lon1 = dToR(lo1)
        let lat2 = dToR(la2)
        let lon2 = dToR(lo2)
        
        return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1)) / 1609.344
    }
    
    func findNearby(radius: Double, completionHandler: @escaping ([User]) -> Void){
        var resultUsers = [User]()
        if let currentUser = Auth.auth().currentUser {
            UserService.shared.getUserData { (users) in
                for user in users{
                    if user.name == currentUser.displayName{
                        for other in users{
                            if user.name != other.name{
                                //filter the movie
                                if other.favouriteMovies.contains(self.movieName!){
                                    //filter the age
                                    if other.age < self.age!{
                                        //filter the distance
                                        if self.haversineDinstance(la1: user.latitude, lo1: user.longtitude, la2: other.latitude, lo2: other.longtitude) < radius {
                                            resultUsers.append(other)
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
                completionHandler(resultUsers)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ResultSegue":
            
            let resultTableViewController = segue.destination as! ResultTableTableViewController
            resultTableViewController.configure(age: self.age!, radius: self.radius!, resultUsers: self.resultUsers)
            
        default:
            assert(false, "Unhandled Segue from Info Controller")
        }
    }
    
}

