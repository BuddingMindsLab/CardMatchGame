//
//  ViewController.swift
//
//  Main view controller used to control the game view
//
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-01-27.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

// Should only manage the view
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Making a delegate to communicate with
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var targetCard: UIImageView!
    @IBOutlet weak var pattern: UIImageView!
    
    var player: AVAudioPlayer!
    
    var model = CardModel()
    var csvWriter = CSVWriter()
    var pHandler = PausedHandler()
    
    var cardArray = [Card]()
    var targetArray = [Card]()
    
    var targetCount = 0
    var targetCardName = String()
    
    var firstCard:IndexPath? // The first card flipped by user

    var participId: Int = 0 // Set to the participant ID entered on the first screen
    var expName: String = ""
    
    var trialWidth: CGFloat = 0.0
    var trialHeight: CGFloat = 0.0
    
    var cardCount = 8   // Number of cards shown (8 if non-prime layout, 12 if prime layout)
    
    var phase = 1   // The current layout phase the user is on (1-6)
    
    var currentLine = [String]() // The line that we're going to send to the CSVWriter
    
    var unp = true
    
    var time = -1
    var timeRT = 0
    var firstTouch = true
    
    var trialNum = 1
    
    
    @IBOutlet weak var instr3Image: UIImageView!
    
    @IBOutlet weak var videoBckg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if skippingPhases {
            print(Int(participantId)! % 32)
            // These participants will do the second half
            if Int(participantId)! % 32 > 15 {
                phase = 2
                
                if unpausing {
                    phase = 4
                    pHandler.removePaused(id: "\(participantId)-\(csvWriter.getLatestVersion())")
                }
            } else {
                phase = 1
                
                if unpausing {
                    phase = 3
                    pHandler.removePaused(id: "\(participantId)-\(csvWriter.getLatestVersion())")
                }
            }
        } else {

            if unpausing {
                phase = 3
                pHandler.removePaused(id: "\(participantId)-\(csvWriter.getLatestVersion())")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("the phase is: \(phase)")
        participId = Int(participantId)!
        expName = experimentName
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Get the correct-sound.wav file and load it into player
        let path = Bundle.main.path(forResource: "correct-sound", ofType: "wav")!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        
        // Sets up the orderArray with the proper order depending on id
        model.setOrderArray(id: participId)
        
        cardArray = model.getMatchingCards(phase: phase)
        
        cardCount = cardArray.count
        
        // Get target cards
        targetArray = model.getTargetCards(phase: phase)
        
        // Play the first video
        if phase == 1 {
            let file = model.getVidName(phase: phase)
            playVideo(from: file)
            
        // Play the video to start unpause part
        } else if (phase == 3 || phase == 4) && unpausing {
            let file = model.getVidName(phase: phase)
            playVideo(from: file)
        }
        
        // Set target card image
        targetCard.image = UIImage(named:targetArray[targetCount].imageName)
        targetCardName = targetArray[targetCount].imageName
        targetCount += 1
        
        
        trialWidth = 0.2 * self.view.frame.size.width;
        trialHeight = 0.2 * self.view.frame.size.height;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // UICollectionView Protocol Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of cards we will be returning
        return cardCount
    }
    var a = 0
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Returns cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlippableCardCell", for: indexPath) as! CardCollectionViewCell
        
        // Update the cardArray
        cardArray = model.getMatchingCards(phase: phase)
        
        // Sets the card that's to be displayed via the setCard method
        let card = cardArray[indexPath.row]
        
        // Assign that card to the cell
        cell.setCard(card)
        
        // Set pattern background
        pattern.image = UIImage(named:model.bckgArray[phase - 1])
        
        let cardPositions = model.getCardPositions(phase: phase)
        
        // Set cardCount based on the amount of positions returned
        cardCount = cardPositions.count
        
        // Set the card position by centerpoints retrieved from CardModel class
        cell.center = cardPositions[indexPath.row]
        
        // Assign the card it's position
        cardArray[indexPath.row].loc = cell.center

        
        return cell
    }
    
 
    // Get location of the target card
    func getTargetLoc() -> Int {
        var card = Card()
        
        for i in cardArray {
            if i.imageName == targetCardName {
                card = i
            }
        }
        
        return model.getCardLoc(point: card.loc, phase: phase)
    }
    
    // Helper function to send current line to the csv writer
    func sendToCsv(cell: CardCollectionViewCell, card: Card) {
        // 1 - experiment name
        currentLine.append(expName)
        
        // 2 - group ID
        var gid = (participId % 16) + 1
        
        if gid == 13 {
            gid = 1
        } else if gid == 14 {
            gid = 2
        } else if gid == 15 {
            gid = 3
        } else if gid == 16 {
            gid = 4
        }
        
        currentLine.append(String(gid))
        
        // 3 - subject #
        currentLine.append(String(participId))
        
        // 4 - block ID
        currentLine.append(String(phase))
        
        // 5 - configuration/layout ID
        currentLine.append(String(model.getConID(phase: phase)))
        
        // 6 - trial #
        currentLine.append(String(trialNum))
        
        // 7 - goal location
        currentLine.append(String(getTargetLoc()))
        
        // 8 - goal object
        currentLine.append(model.getObjName(num: Int(targetCardName.digits)!))
        
        // 9 - rep #
        currentLine.append(String(attempts + 1))
        
        // 10 - touch location
        currentLine.append(String(model.getCardLoc(point: cell.center, phase: phase)))
        
        // 11 - touch object
        if card.imageName == "" {
            currentLine.append("grayed-out")
        } else {
            currentLine.append(model.getObjName(num: Int(card.imageName.digits)!))
        }
        
        // 12 - touch time (from last thing touched/level start)
        timeRT = Int(CACurrentMediaTime() * 1000) - time

        currentLine.append(String(timeRT))
        
        // 13 - Accuracy (1/0) if the touch obj = goal obj
        if currentLine[7] == currentLine[10] {
            currentLine.append(String(1))
        } else {
            currentLine.append(String(0))
        }
        
        csvWriter.writeLine(elements: currentLine)
        
        currentLine = [String]()
    }
    
    var playerLayer = AVPlayerLayer()
    var videoNotPlaying = true
    
    // Function used to play a transition video when changing layouts
    private func playVideo(from file:String) {
        let file = file.components(separatedBy: ".")
        
        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        
        // Disable touch and make background black
        self.view.isUserInteractionEnabled = false
        videoBckg.alpha = 1
        
        videoNotPlaying = false
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopScreenSaver), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    var written = false
    
    // Function used to return to game after video completes playback
    @objc func stopScreenSaver(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.playerLayer.removeFromSuperlayer()
            // Enable touch and remove black background
            self.view.isUserInteractionEnabled = true
            self.videoBckg.alpha = 0
            self.videoNotPlaying = true
            
            // Show the instructions for phase 5/6 before phase 5
            if self.phase == 5 {
                self.instr3Image.alpha = 1
            
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.instr3Image.alpha = 0
                }
            }
            
            
            if self.time == -1 {
                // Set up the time and write block start
                self.time = Int(CACurrentMediaTime() * 1000)
                self.firstTouch = true
            }
            
            if self.written == false {
                self.writeBlockTime()
                self.written = true
            }
        }
    }
    
    // Function that writes start/end block time to the data file
    func writeBlockTime() {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let date = formatter.string(from: currentDateTime)
        
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        
        let clockTime = formatter.string(from: currentDateTime)
        
        var line = ["","","","","","","","","","","","",""]
        line.append("\(date) \(clockTime)")
        csvWriter.writeLine(elements: line)
    }
    
    // Determines what happens when a cell was clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let card = cardArray[indexPath.row]
        
        if written == true {
            written = false
        }
        sendToCsv(cell: cell, card: card)
        trialNum += 1
        
        if !card.greyedOut {
            // Only allow one card to be flipped at a time
            if !card.isFlipped {
                if firstCard == nil {
                    if phase == 5 || phase == 6 {
                        self.view.isUserInteractionEnabled = false
                    }
                    card.isFlipped = true
                    firstCard = indexPath
                    cell.flip(phase: phase)
                    
                    card.touches += 1
                    print("\(card.imageName) has been touched \(card.touches) times")
                    
                    // Check if the flipped card matches the target card
                    checkForMatch(indexPath)
                    if phase == 5 || phase == 6 {
                        self.view.isUserInteractionEnabled = true
                    }
                }
            } else {
                card.isFlipped = false
                cell.flipBack(phase: phase)
                
                firstCard = nil
            }
        } else {
            card.touches += 1
            print("\(card.imageName) has been touched \(card.touches) times")
        }
    }
    
    func playMatchSound() {
        player.play()
    }
    
    // ---------------------------- Card Removal Methods -----------------------------
    
    var attempts = 0
    var prevAverageTouches: Float? = 0
    var curAverageTouches: Float? = 0
    
    // Calculate average touches for moving on
    func getAverageTouches() -> Float {
        var avg: Float = 0
        var div: Float = 0
        
        avg += Float(getTotalTouches())
        
        if cardArray.count == (numGreyedOut + numFlippable) {
            div = Float(numFlippable)
        } else {
            div = Float(numGreyedOut)
        }
        return Float(avg / div)
    }
    
    // Get total touches this attempt
    func getTotalTouches() -> Int {
        var touches = 0
        
        for c in cardArray {
            touches += c.touches
        }
        
        return touches
    }
    
    // Reset all card touches to 0 for next attempt
    func resetCardTouches() {
        for c in cardArray {
            c.touches = 0
        }
    }
    
    // Function that "pauses" the game by saving particpant ID in file allowing for continuation of part2
    func pause() {
        pHandler.writePaused(id: String(participId))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.performSegue(withIdentifier: "gameToPause", sender: self)
        }
    }
    
    func checkForMatch(_ flippedIndex:IndexPath) {
        
        // Get cell for the matched card
        let cell = collectionView.cellForItem(at: firstCard!) as? CardCollectionViewCell
        
        // Get card for the matched card
        let card = cardArray[firstCard!.row]
        
        if card.imageName == targetCardName || phase == 5 || phase == 6 { // Match
            // Flip card back and change target card after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                if self.phase != 5 && self.phase != 6 {
                    self.player.play()
                }
                
                card.isFlipped = false
                cell?.flipBack(phase: self.phase)

                if self.targetCount <= self.targetArray.count - 1 {
                    // Get next target car
                    self.targetCard.image = UIImage(named:self.targetArray[self.targetCount].imageName)
                    self.targetCardName = self.targetArray[self.targetCount].imageName
                    
                    // Increment counter
                    self.targetCount += 1
                } else if self.targetCount == self.targetArray.count {
                    self.view.isUserInteractionEnabled = false
                    if self.phase == 5 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            card.isFlipped = false
                            self.firstCard = nil
                            
                            if skippingPhases {
                                self.writeBlockTime()
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                    self.performSegue(withIdentifier: "gameToEnd", sender: self)
                                }
                            } else {
                                self.phase += 1
                                self.writeBlockTime()
                                self.trialNum = 1
                                
                                self.targetArray = self.model.getTargetCards(phase: self.phase)
                                // Set target card image
                                self.targetCard.image = UIImage(named:self.targetArray[0].imageName)
                                self.targetCardName = self.targetArray[0].imageName
                                self.targetCount = 1
                                self.cardCount = self.model.getNextOrderNum(phase: self.phase - 1)
                                
                                self.attempts = 0
                                self.resetCardTouches()
                                let trans = self.model.isTransitionToNewBackground(phase: self.phase)
                                if trans {
                                    let file = self.model.getVidName(phase: self.phase)
                                    self.playVideo(from: file)
                                }
                                if self.videoNotPlaying {
                                    self.view.isUserInteractionEnabled = true
                                }
                                self.collectionView.reloadData()
                            }
                        }
                    } else if self.phase == 6 {
                        self.writeBlockTime()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            self.performSegue(withIdentifier: "gameToEnd", sender: self)
                        }
                    } else {
                        self.attempts += 1
                        self.prevAverageTouches = self.curAverageTouches
                        self.curAverageTouches = self.getAverageTouches()
                        
                        // Shuffle the target cards
                        self.targetArray = self.model.shuffleTargetCards(old: self.targetArray)
                        
                        print("\(self.attempts) attempts, prevAvg: \(self.prevAverageTouches ?? -1), curAvg: \(self.curAverageTouches ?? -1)")
                        
                        if self.attempts < 3 || self.curAverageTouches != 1 || self.prevAverageTouches != 1 {
                            self.view.isUserInteractionEnabled = true
                            self.targetCard.image = UIImage(named:self.targetArray[0].imageName)
                            self.targetCardName = self.targetArray[0].imageName
                            self.targetCount = 1
                        } else if self.attempts > 2 && self.curAverageTouches == 1 && self.prevAverageTouches == 1 {
                            // After getting the layout perfectly twice in a row, move on to the next layout
                            if skippingPhases {
                                self.phase += 2
                            } else {
                                self.phase += 1
                            }
                            self.trialNum = 1
                            self.writeBlockTime()
                            self.cardCount = self.model.getNextOrderNum(phase: self.phase - 1)
                            self.curAverageTouches = 0.0
                            self.prevAverageTouches = 0.0
                            self.attempts = 0
                            self.resetCardTouches()
                            

                            if (self.phase == 3 && !unpausing) || (skippingPhases && self.phase == 4 && !unpausing) {
                                self.pause()
                            } else {
                                self.targetArray = self.model.getTargetCards(phase: self.phase)
                                // Set target card image
                                self.targetCard.image = UIImage(named:self.targetArray[0].imageName)
                                self.targetCardName = self.targetArray[0].imageName
                                self.targetCount = 1
                                let trans = self.model.isTransitionToNewBackground(phase: self.phase)
                                if trans {
                                    let file = self.model.getVidName(phase: self.phase)
                                    self.playVideo(from: file)
                                }
                                if self.videoNotPlaying {
                                    self.view.isUserInteractionEnabled = true
                                }
                                self.collectionView.reloadData()
                            }
                        }
                        self.resetCardTouches()
                    }
                }
                
                self.firstCard = nil
            }
        } else { // No match
            card.isFlipped = false
            
            // Delay the flipback so user sees the card they flipped
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                cell?.flipBack(phase: self.phase)
                
                self.firstCard = nil
            }
        }
    }
            
}

