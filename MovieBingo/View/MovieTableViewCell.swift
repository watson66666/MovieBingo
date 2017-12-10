//
//  MovieTableViewCell.swift
//  MovieBingo
//
//  Created by Watson Li on 11/7/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet var movieLabel : UILabel!
    @IBOutlet var MovieImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        MovieImageView.contentMode = .scaleAspectFit
        // Configure the view for the selected state
    }

}
