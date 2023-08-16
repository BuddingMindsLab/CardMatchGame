//
//  CardModel.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-01-27.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import Foundation
import UIKit
import GameKit

// Shuffling extensions from community wiki
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

func getRS() -> GKMersenneTwisterRandomSource {
    return GKMersenneTwisterRandomSource(seed: UInt64(participantId)!)
}

// This variable represents if we want to skip phases and only test each participant on half
var skippingPhases = false

// This is the amount of unique cards you will need for the entire experiment
// With original app you need 28: 2x8 cards for first 2 phases, 2x6 cards for the middle 2 phases
var numCardsNeeded = 28

// This is the amount of cards found in the assets folder
// Change this if you add more cards
var numCardsToChooseFrom = 40

// This is the amount of cards that are greyed out in the prime layouts
var numGreyedOut = 8

// This is the amount of cards that are flippable/not greyed out in the prime layouts
var numFlippable = 6

class CardModel{
    // Used to store final orders of cards
    // cardSets[0] is the order for the 1st phase and the 1st re-test phase
    // cardSets[1] is the order for the 2nd phase and the 2nd re-test phase
    // cardSets[2] and cardSets[3] are the orders for the 2 middle phases respectively
    var cardSets = [[Card]]()
    
    // Used to store the actual card objects that will be used in the orders
    var cardArray = [Card]()
    
    // Used to store the numbers of cards that will be used in the orders
    var cardNumArray = [UInt32]()
    
    var doneOnce = false
    
    var orderArray = [[CGPoint]]()
    var bckgArray = [String]()
    
    // The different card layouts
    var order_A = [CGPoint]()
    var order_A_prime = [CGPoint]()
    var order_B = [CGPoint]()
    var order_B_prime = [CGPoint]()
    var order_C = [CGPoint]()
    var order_C_prime = [CGPoint]()
    
    // These arrays give values for the data that specify touch/goal location
    // THese values are mapped onto the layouts in images provided
    // The order of these numbers should match the order of coordinates in the matching order in the initOrders() function below
    var A_locs = [3, 2, 8, 1, 7, 5, 4, 6]
    var Ap_locs = [3, 2, 8, 1, 7, 5, 4, 6, 9, 11, 10, 12, 13, 14]
    var B_locs = [3, 1, 8, 6, 4, 5, 2, 7]
    var Bp_locs = [3, 1, 8, 6, 4, 5, 2, 7, 11, 12, 10, 9, 13, 14]
    var C_locs = [6, 2, 7, 8, 4, 1, 5, 3]
    var Cp_locs = [6, 2, 7, 8, 4, 1, 5, 3, 9, 10, 12, 11, 13, 14]
    
    // This array gives names to each card. It should be in the same order as the cards in Assets.xcassets
    // ex. if card1 is a ball then the first item in this array should be "ball"
    var obj_names = ["ball", "banana", "bed", "bell", "bird", "boat", "bread", "bus", "butterfly", "cake", "car", "carrot", "chair", "chicken", "chocolate", "clown", "cookie", "crayons", "door", "egg", "fire", "flower", "hat", "ice cream", "cat", "milk", "orange", "pants", "pie", "pig", "dog", "rabbit", "reindeer", "shirt", "shoes", "snowman", "spider", "spoon", "towel", "bear"]

    // Used to determine background image for the layout
    var pink = "pattern - pink.jpg"
    var blue = "pattern - blue.png"
    var orange = "pattern - orange.png"

    // Initialize orders by with arrays of (x,y) coordinates here
    func initOrders() {
        order_A = [CGPoint(x: 191, y: 413), CGPoint(x: 1033, y: 142), CGPoint(x: 702, y: 871), CGPoint(x: 524, y: 169), CGPoint(x: 315, y: 837), CGPoint(x: 603, y: 571), CGPoint(x: 879, y: 344), CGPoint(x: 148, y: 879)]
        
        // These are the flippable locations in the prime layout
        let Ap = [CGPoint(x: 115, y: 132), CGPoint(x: 871, y: 743), CGPoint(x: 390, y: 475), CGPoint(x: 1082, y: 772), CGPoint(x: 490, y: 860), CGPoint(x: 975, y: 526)]
        
        order_A_prime = order_A + Ap

        order_B = [CGPoint(x: 922, y: 247), CGPoint(x: 249, y: 209), CGPoint(x: 934, y: 865), CGPoint(x: 756, y: 554), CGPoint(x: 83, y: 697), CGPoint(x: 326, y: 603), CGPoint(x: 514, y: 264), CGPoint(x: 532, y: 862)]
        
        // These are the flippable locations in the prime layout
        let Bp = [CGPoint(x: 1027, y: 520), CGPoint(x: 282, y: 844), CGPoint(x: 119, y: 480), CGPoint(x: 726, y: 150), CGPoint(x: 370, y: 351), CGPoint(x: 709, y: 367)]

        order_B_prime = order_B + Bp

        order_C = [CGPoint(x: 115, y: 888), CGPoint(x: 957, y: 246), CGPoint(x: 394, y: 710), CGPoint(x: 746, y: 773), CGPoint(x: 613, y: 424), CGPoint(x: 204, y: 187), CGPoint(x: 965, y: 485), CGPoint(x: 142, y: 507)]

        // These are the flippable locations in the prime layout
        let Cp = [CGPoint(x: 673, y: 155), CGPoint(x: 317, y: 414), CGPoint(x: 1007, y: 824), CGPoint(x: 568, y: 753), CGPoint(x: 752, y: 581), CGPoint(x: 170, y: 704)]
        
        order_C_prime = order_C + Cp
    }

    
    // Return the array of flippable cards
    func getMatchingCards(phase: Int) -> [Card] {
        
        if doneOnce == false && !unpausing {

            doneOnce = true
            
            let randomDist = GKRandomDistribution(randomSource: getRS(), lowestValue: 1, highestValue: numCardsToChooseFrom)
            
            // Get 24 cards for 2x 8-card layouts and 2x 4-card layout
            while cardNumArray.count < numCardsNeeded {
                
                // Generate a random card number (between 1 and 40)
                let rand = randomDist.nextInt()
                
                // Ensure no duplicates
                if !cardNumArray.contains(UInt32(rand)) {
                    cardNumArray.append(UInt32(rand))
                }
            }
            
            // Assign the images to card objects
            for num in cardNumArray {
                let card = Card()
                card.imageName = "card\(num)"
                cardArray.append(card)
            }
            
            // Append cards to each card set based on how many are in each layout
            cardSets.append([])
            cardSets.append([])
            cardSets.append([])
            cardSets.append([])
            
            // This first line means that the first 8 cards in the cardArray will be assigned to cardSet 0
            // Notice there are 8 of them. If for example you changed it to have 10 cards in the first layout
            // then cardSets[0] += cardArray[0...9] would be what you'd change the line to
            cardSets[0] += cardArray[0...7]
            cardSets[1] += cardArray[8...15]
            cardSets[2] += cardArray[16...21]
            cardSets[3] += cardArray[22...27]
            
        } else if ((phase == 3 && unpausing) || (phase == 4 && unpausing)) && !doneOnce {
            doneOnce = true
            
            let randomDist = GKRandomDistribution(randomSource: getRS(), lowestValue: 1, highestValue: numCardsToChooseFrom)
            
            // Get 24 cards for 2x 8-card layouts and 2x 4-card layout
            while cardNumArray.count < numCardsNeeded {
                
                // Generate a random card number (between 1 and 40)
                let rand = randomDist.nextInt()
                
                // Ensure no duplicates
                if !cardNumArray.contains(UInt32(rand)) {
                    cardNumArray.append(UInt32(rand))
                }
            }
            
            // Assign the images to card objects
            for num in cardNumArray {
                let card = Card()
                card.imageName = "card\(num)"
                cardArray.append(card)
            }
            
            // Append cards to each card set based on how many are in each layout
            cardSets.append([])
            cardSets.append([])
            cardSets.append([])
            cardSets.append([])
            
            // This first line means that the first 8 cards in the cardArray will be assigned to cardSet 0
            // Notice there are 8 of them. If for example you changed it to have 10 cards in the first layout
            // then cardSets[0] += cardArray[0...9] would be what you'd change the line to
            cardSets[0] += cardArray[0...7]
            cardSets[1] += cardArray[8...15]
            cardSets[2] += cardArray[16...21]
            cardSets[3] += cardArray[22...27]
            
            // Put in unflippable, greyed out cards if this layout has 12 cards
            if orderArray[phase - 1].count == (numGreyedOut + numFlippable) {
                var cardArrayWithGrey = [Card]()
                
                for _ in 0...(numGreyedOut - 1) {
                    let card = Card()
                    card.greyedOut = true
                    cardArrayWithGrey.append(card)
                }
                
                if phase == 3 {
                    for i in 0...(numFlippable - 1) {
                        cardArrayWithGrey.append(cardSets[2][i])
                    }
                } else if phase == 4 {
                    for i in 0...(numFlippable - 1) {
                        cardArrayWithGrey.append(cardSets[3][i])
                    }
                }
                
                return cardArrayWithGrey
            } else {
                return getCardSet(phase: phase)
            }
        } else {
            if orderArray[phase - 1].count == (numGreyedOut + numFlippable) {
                var cardArrayWithGrey = [Card]()
                
                for _ in 0...(numGreyedOut - 1) {
                    let card = Card()
                    card.greyedOut = true
                    cardArrayWithGrey.append(card)
                }
                
                if phase == 3 {
                    for i in 0...(numFlippable - 1) {
                        cardArrayWithGrey.append(cardSets[2][i])
                    }
                } else if phase == 4 {
                    for i in 0...(numFlippable - 1) {
                        cardArrayWithGrey.append(cardSets[3][i])
                    }
                }
                
                return cardArrayWithGrey
            } else {
                return getCardSet(phase: phase)
            }
            
        }

        return getCardSet(phase: phase)
    }
    
    // Returns the set of cards for the phase passed in
    func getCardSet(phase: Int) -> [Card] {
        if phase == 1 || phase == 5 {
            return cardSets[0]
        } else if phase == 2 || phase == 6 {
            return cardSets[1]
        } else if phase == 3 {
            return cardSets[2]
        } else if phase == 4 {
            return cardSets[3]
        }
        return [Card]()
    }
    
    // Return number of cards of next order
    func getNextOrderNum(phase: Int) -> Int {
        return orderArray[phase].count
    }
    
    // Return the array of target cards
    func getTargetCards(phase: Int) -> [Card] {
        var targetArray = [Card]()
        var tan = [UInt32]()
        
        // This determined which slice of the cardNumArray will be returned
        if phase == 1 || phase == 5 {
            tan += cardNumArray[0...7]
        } else if phase == 2 || phase == 6 {
            tan += cardNumArray[8...15]
        } else if phase == 3 {
            tan += cardNumArray[16...21]
        } else if phase == 4 {
            tan += cardNumArray[22...27]
        }
        
        let targetArrayNums = tan.shuffled()
        
        for num in targetArrayNums {
            let card = Card()
            card.imageName = "card\(num)"
            targetArray.append(card)
        }
        
        return targetArray
    }
    
    // Return a re-shuffle of target cards, with constraint that last of old != first of new
    func shuffleTargetCards(old: [Card]) -> [Card] {
        var new = old.shuffled()
        
        // Ensure the constraint holds
        while new[0].imageName == old[old.count - 1].imageName {
            new = old.shuffled()
        }
        
        return new
    }
    
    // Helper function to scale the x,y coordinates depending on screen size and return resulting CGPoint
    func scaleCoordsToPoint(points: [CGPoint]) -> [CGPoint] {
        
        // Get the size of the screen
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        // The original coordinates should be defined in terms of the 12.9" iPad (1366x1024)
        let origX:Float = 1366.0
        let origY:Float = 1024.0
        
        // Mutated list
        var ret = [CGPoint]()
        
        for p in points {
            // Calculate the new coords
            let newX = Float(p.x) * Float(width)/origX
            let newY = Float(p.y) * Float(height)/origY
            
            ret.append(CGPoint(x: Int(newX), y: Int(newY)))
        }
        
        return ret
    }
    
    // Initialize the orders and set the orders array which determines what layouts they'll see
    // in what order based on id number
    func setOrderArray(id: Int) {
        initOrders()
        
        
        // A = pink, B = blue, C = orange
        switch id % 16 {
            case 0:
                orderArray.append(order_A)
                orderArray.append(order_B)
                orderArray.append(order_A_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_A)
                orderArray.append(order_B)
                
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
            case 1:
                orderArray.append(order_A)
                orderArray.append(order_B)
                orderArray.append(order_C_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_A)
                orderArray.append(order_B)
            
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(pink)
                bckgArray.append(blue)
            case 2:
                orderArray.append(order_B)
                orderArray.append(order_A)
                orderArray.append(order_A_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_B)
                orderArray.append(order_A)
            
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(pink)
            case 3:
                orderArray.append(order_B)
                orderArray.append(order_A)
                orderArray.append(order_C_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_B)
                orderArray.append(order_A)
            
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(pink)
            case 4:
                orderArray.append(order_C)
                orderArray.append(order_B)
                orderArray.append(order_B_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_C)
                orderArray.append(order_B)
            
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(blue)
            case 5:
                orderArray.append(order_C)
                orderArray.append(order_B)
                orderArray.append(order_A_prime)
                orderArray.append(order_B_prime)
                orderArray.append(order_C)
                orderArray.append(order_B)
            
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(blue)
            case 6:
                orderArray.append(order_B)
                orderArray.append(order_C)
                orderArray.append(order_B_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_B)
                orderArray.append(order_C)
            
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(orange)
            case 7:
                orderArray.append(order_B)
                orderArray.append(order_C)
                orderArray.append(order_A_prime)
                orderArray.append(order_B_prime)
                orderArray.append(order_B)
                orderArray.append(order_C)
            
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(blue)
                bckgArray.append(orange)
            case 8:
                orderArray.append(order_A)
                orderArray.append(order_C)
                orderArray.append(order_C_prime)
                orderArray.append(order_B_prime)
                orderArray.append(order_A)
                orderArray.append(order_C)
            
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
            case 9:
                orderArray.append(order_A)
                orderArray.append(order_C)
                orderArray.append(order_B_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_A)
                orderArray.append(order_C)
            
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(orange)
            case 10:
                orderArray.append(order_C)
                orderArray.append(order_A)
                orderArray.append(order_C_prime)
                orderArray.append(order_B_prime)
                orderArray.append(order_C)
                orderArray.append(order_A)
            
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(pink)
            case 11:
                orderArray.append(order_C)
                orderArray.append(order_A)
                orderArray.append(order_B_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_C)
                orderArray.append(order_A)
            
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(orange)
                bckgArray.append(pink)
            case 12:
                orderArray.append(order_A)
                orderArray.append(order_B)
                orderArray.append(order_A_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_A)
                orderArray.append(order_B)
                
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
            case 13:
                orderArray.append(order_A)
                orderArray.append(order_B)
                orderArray.append(order_C_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_A)
                orderArray.append(order_B)
                
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(pink)
                bckgArray.append(blue)
            case 14:
                orderArray.append(order_B)
                orderArray.append(order_A)
                orderArray.append(order_A_prime)
                orderArray.append(order_C_prime)
                orderArray.append(order_B)
                orderArray.append(order_A)
                
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(blue)
                bckgArray.append(pink)
            case 15:
                orderArray.append(order_B)
                orderArray.append(order_A)
                orderArray.append(order_C_prime)
                orderArray.append(order_A_prime)
                orderArray.append(order_B)
                orderArray.append(order_A)
                
                bckgArray.append(blue)
                bckgArray.append(pink)
                bckgArray.append(orange)
                bckgArray.append(pink)
                bckgArray.append(blue)
                bckgArray.append(pink)
            default:
                print("Error with participant ID")
        }
        
        var newOrderArray = [[CGPoint]]()
        
        for order in orderArray {
            newOrderArray.append(scaleCoordsToPoint(points: order))
        }
        
        orderArray = newOrderArray
    }
    
    // Get the letter designation of the current layout
    func getConID(phase: Int) -> String {
        let cur = orderArray[phase - 1]
        
        if cur == order_A {
            return "A"
        } else if cur == order_B {
            return "B"
        } else if cur == order_C {
            return "C"
        } else if cur == order_A_prime {
            return "A'"
        } else if cur == order_B_prime {
            return "B'"
        } else if cur == order_C_prime {
            return "C'"
        } else {
            return "error"
        }
    }
    
    // Get obj name given the card number
    func getObjName(num: Int) -> String {
        return obj_names[num - 1]
    }
    
    // Get the number designation of the card touched based on current layout (check provided mapping)
    func getCardLoc(point: CGPoint, phase: Int) -> Int {
        let cid = getConID(phase: phase)
        var ord = [CGPoint]()
        var locs = [Int]()
        
        switch cid {
        case "A":
            ord = order_A
            locs = A_locs
        case "B":
            ord = order_B
            locs = B_locs
        case "C":
            ord = order_C
            locs = C_locs
        case "A'":
            ord = order_A_prime
            locs = Ap_locs
        case "B'":
            ord = order_B_prime
            locs = Bp_locs
        case "C'":
            ord = order_C_prime
            locs = Cp_locs
        default:
            print("Card Location Error!")
        }
        
        let idx = ord.firstIndex(of: point)
        
        return locs[idx!]
    }
    
    // Get the bckg that goes with the current layout
    func getBckg(phase: Int) -> String {
        return bckgArray[phase - 1]
    }
    
    // Return array of centerpoint locations for cards depending on which phase we're in (1-6)
    func getCardPositions(phase: Int) -> [CGPoint] {
        return orderArray[phase - 1]
    }
    
    // Determines if we're transitioning between different backgrounds and need a video
    func isTransitionToNewBackground(phase: Int) -> Bool {
        var first = getConID(phase: phase - 1)
        var second = getConID(phase: phase)
        
        if first.count == 2 {
            let pre = first.prefix(1)
            first = "" + pre
        } else if second.count == 2 {
            let pre = second.prefix(1)
            second = "" + pre
        }
        
        if skippingPhases {
            var f = getConID(phase: phase - 1)
            if phase != 1 {
                f = getConID(phase: phase - 2)
            }
            var s = getConID(phase: phase)
            
            print("first: \(f) second: \(s)")
            
            if f.count == 2 {
                let pre = f.prefix(1)
                f = "" + pre
            } else if s.count == 2 {
                let pre = s.prefix(1)
                s = "" + pre
            }
            
            return f != s
        }
        
        return first != second
    }
    
    // Returns number of video to play
    func getVidName(phase: Int) -> String {
        var first = ""
        let second = getConID(phase: phase)
        
        if phase == 1 || ((phase == 3 && unpausing) || (phase == 4 && skippingPhases && unpausing)) {
            first = "Start"
        } else {
            if skippingPhases {
                if phase == 1 {
                    first = getConID(phase: phase - 1)
                } else {
                    first = getConID(phase: phase - 2)
                }
            } else {
                first = getConID(phase: phase - 1)
            }
        }
        
        if first == "Start" && (second == "A" || second == "A'") {
            return "start to pink.mp4"
        } else if first == "Start" && (second == "B" || second == "B'"){
            return "start to blue.mp4"
        } else if first == "Start" && (second == "C" || second == "C'") {
            return "start to orange.mp4"
        } else if (first == "A" || first == "A'") && (second == "B" || second == "B'") {
            return "pink to blue.mp4"
        } else if (first == "A" || first == "A'") && (second == "C" || second == "C'")  {
            return "pink to orange.mp4"
        } else if (first == "B" || first == "B'") && (second == "A" || second == "A'") {
            return "blue to pink.mp4"
        } else if (first == "B" || first == "B'") && (second == "C" || second == "C'") {
            return "blue to orange.mp4"
        } else if (first == "C" || first == "C'") && (second == "A" || second == "A'") {
            return "orange to pink.mp4"
        } else /* if (first == "C" || first == "C'") && (second == "B" || second == "B'")  */ {
            return "orange to blue.mp4"
        }
    }
}
