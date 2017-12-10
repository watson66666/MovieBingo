//
//  MovieModel.swift
//  MovieBingo
//
//  Created by Watson Li on 11/5/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import Foundation
import SwiftSoup

struct Movie {
    let title : String
    let duration : String
    let genre : String
    let description : String
    let director : String
    let stars : String
    let imageURL : String
}

class MovieModel {
    static let sharedInstance = MovieModel()
    
    fileprivate var allMovies = [Movie]()
    
    fileprivate init() {
        
        let myURLString = "http://www.imdb.com/movies-in-theaters/?ref_=nv_mv_inth_1"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            guard let doc: Document = try? SwiftSoup.parse(myHTMLString) else {return}
            let listMovieItems = try doc.select("div[itemscope]>table>tbody>tr")
            let images = try listMovieItems.select("td>div>a>div>img")
            let overviews = try listMovieItems.select("td+td")
            
            var allImageURL = [String]()
            for i in images{
                allImageURL.append(try i.attr("src"))
            }
            for i in overviews{
                let title = try i.select("h4>a").attr("title")
                let duration = try i.select("p>time").text()
                let genre = try i.select("p>span").text()
                let description = try i.select("div.outline").text()
                let director = try i.select("div.txt-block").first()!.text()
                let stars = try i.select("div.txt-block+div.txt-block").first()!.text()
                let imageURLIndex = overviews.array().index(of: i)
                let imageURL = allImageURL[imageURLIndex!]
                
                let aMovie = Movie(title: title, duration: duration, genre: genre, description: description, director: director, stars: stars, imageURL: imageURL)
                allMovies.append(aMovie)
            }
            
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    var numberOfRows : Int {get {return allMovies.count}}
    
    func movieFor(indexPath:IndexPath) -> Movie {
        return allMovies[indexPath.row]
    }
    
}

