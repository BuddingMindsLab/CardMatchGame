//
//  Card.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-01-27.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import Foundation
import UIKit

class Card {
    
    var imageName = ""
    var isFlipped = false
    var isMatched = false
    var touches = 0
    var greyedOut = false
    var loc = CGPoint(x: -1, y: -1)
}
