//
//  GameCompleteViewController.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-02-24.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit

class GameCompleteViewController: UIViewController {
    
    // Quit the game when button pressed
    @IBAction func quitButton(_ sender: Any) {
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
