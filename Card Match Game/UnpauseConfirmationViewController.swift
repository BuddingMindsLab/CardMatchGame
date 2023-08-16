//
//  UnpauseConfirmationViewController.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-03-14.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit

var instructionToShow = -1

class UnpauseConfirmationViewController: UIViewController {

    // Unpause the game
    @IBAction func unpauseButton(_ sender: Any) {
        unpausing = true
        instructionToShow = 2
        
        // Leave this code in to display the instruction screen before part 2 starts
        performSegue(withIdentifier: "unpauseCheckToInstr", sender: self)
        
        // Uncomment this code to skip the instruction screen before part 2 starts and go right to the game
        // performSegue(withIdentifier: "unpauseToGame", sender: self)
    }
    
    // Restart the game with this ID
    @IBAction func restartButton(_ sender: Any) {
        unpausing = false
        instructionToShow = 1
        
        // Leave this code in to display the instruction screen before part 1 starts
        performSegue(withIdentifier: "unpauseCheckToInstr", sender: self)
        
        // Uncomment this code to skip the instruction screen before part 1 starts and go right to the game
        // performSegue(withIdentifier: "unpauseToGame", sender: self)
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
