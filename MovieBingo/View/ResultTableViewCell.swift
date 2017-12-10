//
//  ResultTableViewCell.swift
//  MovieBingo
//
//  Created by Watson Li on 11/12/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet var resultUserName: UILabel!
    @IBOutlet var resultUserImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addFriend(_ sender: UIButton) {
    }
    
}
