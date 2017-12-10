//
//  WelcomeViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/5/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
    }

    @IBAction func unwindtoWelcomeView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    


}
