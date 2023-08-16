//
//  IDScreenViewController.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-02-10.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVKit

var participantId = ""
var experimentName = "version1"
var unpausing = false

extension UIViewController {
    
    // Original toast function made by Stack Overflow user "Mr.Bean",
    // edited for my purposes
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height * 0.7, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 7.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

class IDScreenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var idTextBox: UITextField!
    @IBOutlet weak var nameTextBox: UITextField!
    
    var pausedHandler = PausedHandler()
    
    // When the submit button pressed, check if this user ID is paused and handle accordingly
    @IBAction func submitPressed(_ sender: UIButton) {
        if (idTextBox.text != "") {
            participantId = idTextBox.text!
            
            if nameTextBox.text != "" {
                experimentName = nameTextBox.text!
            } 
            print("expName: \(experimentName)")
            let num = Int(participantId)
            
            checkPaused()
            
            if num == nil {
                showToast(message: "Please enter a numeric ID")
            }
        }
    }
    
    // Check if user ID is paused and perform segue properly
    func checkPaused() {
        if pausedHandler.checkPaused(id: participantId) {
            performSegue(withIdentifier: "idToUnpauseCheck", sender: self)
        } else {
            instructionToShow = 1
            
            // Leave this code in to show the instruction page before starting the experiment
            performSegue(withIdentifier: "idToInstr", sender: self)
            
            // Uncomment this code to skip over the instruction page before starting the experiment
            // performSegue(withIdentifier: "idToGame", sender: self)
        }
    }
    
    // Hide the keyboard when touched outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        idTextBox.resignFirstResponder()
        nameTextBox.resignFirstResponder()
        return (true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.idTextBox.delegate = self
        self.nameTextBox.delegate = self
        
        nameTextBox.text = experimentName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
