//
//  InfoViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/10/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var directorLabel: UILabel!
    @IBOutlet var starsTextView: UITextView!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var findSomeoneButton: UIButton!
    @IBOutlet var favouriteButton: UIBarButtonItem!
    
    let movieModel = MovieModel.sharedInstance
    
    var indexPath: IndexPath?
    var movieTitle: String?
    var movieImageURL: String?
    var genre: String?
    var director: String?
    var stars: String?
    var duration: String?
    var movieDescription: String?
    var favourite: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.numberOfLines = 2
        titleLabel.text = movieTitle
        genreLabel.text = genre
        directorLabel.text = director
        starsTextView.text = stars
        durationLabel.text = duration
        descriptionTextView.text = movieDescription
        movieImageView.contentMode = .scaleAspectFit
        
        let inList = UserService.shared.favouriteMovie.contains(movieModel.movieFor(indexPath: indexPath!).title)
        favouriteButton.title = inList ? "Remove from Favourite" : "Add to Favourite"
        
        let imgURL = URL(string: movieImageURL!)
        let task = URLSession.shared.dataTask(with: imgURL!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.sync() {
                self.movieImageView.image = UIImage(data: data)
            }
        }
        task.resume()
        
    }
    
    func configureInfo(indexpath: IndexPath) {
        self.indexPath = indexpath
        let movie = movieModel.movieFor(indexPath: indexpath)
        movieTitle = movie.title
        genre = movie.genre
        director = movie.director
        stars = movie.stars
        movieDescription = movie.description
        duration = movie.duration
        movieImageURL = movie.imageURL
        
    }
    
    @IBAction func toggleFavourite(_ sender: UIBarButtonItem) {
        let movie = movieModel.movieFor(indexPath: indexPath!)
        let inList = UserService.shared.favouriteMovie.contains(movie.title)
        
        sender.title = inList ? "Add to Favourite" : "Remove from Favourite"
        
        updateFavouriteFor(movie: movie)
    }
    
    func updateFavouriteFor(movie: Movie){
        let inList = UserService.shared.favouriteMovie.contains(movieModel.movieFor(indexPath: indexPath!).title)
        let favouriteMovieRef = UserService.shared.POST_DB_REF.child("\(String(describing: UserService.shared.currentUser!.userId))").child("favouriteMovies")
        
        if !inList, !UserService.shared.favouriteMovie.contains(movie.title){
            UserService.shared.favouriteMovie.append(movie.title)
        }
        
        if inList, UserService.shared.favouriteMovie.contains(movie.title){
            UserService.shared.favouriteMovie = UserService.shared.favouriteMovie.filter { $0 != movie.title }
        }
        
        favouriteMovieRef.setValue(UserService.shared.favouriteMovie)
        
        UserService.shared.updateFavouriteMovie()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var searchViewController : SearchViewController?
        
        switch segue.identifier! {
        case "SearchSegue":
            searchViewController = segue.destination as? SearchViewController
            searchViewController?.configure(movieTitle: movieTitle!)
            
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
}

