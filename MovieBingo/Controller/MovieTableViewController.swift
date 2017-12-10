//
//  MovieTableViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/7/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class MovieTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let movieModel = MovieModel.sharedInstance
    let locationManager = CLLocationManager()
    var showFavourite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        
        UserService.shared.updateFavouriteMovie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined, .denied:
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
           
            default:
                break
            }
        }
        
    }
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        
        let timer = Timer.scheduledTimer(withTimeInterval: 15*60, repeats: true) { (Timer) in
            self.updateLocationWith(longtitude: longitude, latitude:latitude)
        }
        timer.fire()
    }
    
    func updateLocationWith(longtitude: Double, latitude: Double){
        if let currentUser = UserService.shared.currentUser{
            let ref = UserService.shared.POST_DB_REF.child(currentUser.userId)
            ref.updateChildValues([
                "longtitude": longtitude,
                "latitude": latitude
                ])
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieModel.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        
        // Configure the cell
        let movie = movieModel.movieFor(indexPath: indexPath)
        cell.movieLabel.text = movie.title

        let imgURL = URL(string: movie.imageURL)
        let task = URLSession.shared.dataTask(with: imgURL!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.sync() {
                cell.MovieImageView.image = UIImage(data: data)
            }
        }
        task.resume()
        
        return cell
    }
    
    @IBAction func toggleFavourite(_ sender: UIBarButtonItem) {
        showFavourite = !showFavourite
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if showFavourite{
            if !UserService.shared.favouriteMovie.contains(movieModel.movieFor(indexPath: indexPath).title){
                return 0
            }
        }
        return 100.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var infoViewController : InfoViewController?
        
        switch segue.identifier! {
        case "UserSegue": break
        case "ChatSegue": break
        case "InfoSegue":
            infoViewController = segue.destination as? InfoViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            infoViewController?.configureInfo(indexpath:indexPath)
        default:
            assert(false, "Unhandled Segue")
        }
    }
}
