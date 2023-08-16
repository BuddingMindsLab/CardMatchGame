//
//  CardCollectionViewCell.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-01-27.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var frontImageView: UIImageView!
    
    
    @IBOutlet weak var backImageView: UIImageView!
    
    var card: Card?
    
    // Function that sets up a card with its card object
    func setCard(_ card: Card) {
        if !card.greyedOut {
            self.card = card
            
            frontImageView.image = UIImage(named: card.imageName)
            backImageView.image = UIImage(named: "card back.png")
            
            if card.isFlipped { // Show front of card
                UIView.transition(from: backImageView, to: frontImageView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
                
            } else { // Show back of card
                UIView.transition(from: frontImageView, to: backImageView, duration: 0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            }
        } else {
            backImageView.image = UIImage(named: "card back greyed out.png")
        }
    }
    
    // Function that determines what happens when it's flipped
    func flip(phase: Int) {
        if phase != 5 && phase != 6 {
            // Transition between the 2 images of a card cell
            UIView.transition(from: backImageView, to: frontImageView, duration: 0.7, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        } else if phase == 5 || phase == 6 {
            backImageView.image = UIImage(named: "card back highlighted.png")
            UIView.transition(from: backImageView, to: backImageView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], completion: nil)
        }
    }
    
    // Function that determines what happens when it's flipped back
    func flipBack(phase: Int) {
        if phase != 5 && phase != 6 {
            // Transition back between the 2 images of a card cell
            UIView.transition(from: frontImageView, to: backImageView, duration: 0.7, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        } else if phase == 5 || phase == 6 {
            backImageView.image = UIImage(named: "card back.png")
            UIView.transition(from: backImageView, to: backImageView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], completion: nil)
        }
    }
    
    // Function for removing cards
    func remove() {
        // Make both images invisible
        backImageView.alpha = 0
        frontImageView.alpha = 0
    }
}
