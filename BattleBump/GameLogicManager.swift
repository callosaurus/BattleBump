//
//  GameLogicManager.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-04-29.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class GameLogicManager: NSObject {
    
    @objc var myConfirmedMove = ""
    @objc var theirConfirmedMove = ""
    @objc var roundsPlayedNumber = 0
    @objc var myWinsNumber = 0
    @objc var opponentWinsNumber = 0
    
    @objc func pickRandomMove() {
        let i = arc4random_uniform(3)
        switch i {
        case 0:
            self.myConfirmedMove = "Rock"
        case 1:
            self.myConfirmedMove = "Paper"
        case 2:
            self.myConfirmedMove = "Scissors"
        default:
            break
        }
        
    }
    
    @objc func generateResultsLabelWithMoves() -> String {
        var computedString = ""
        if (self.myConfirmedMove == self.theirConfirmedMove) {
            computedString = "\(self.myConfirmedMove) ties \(self.theirConfirmedMove)"
        }
        else {
            if (self.myConfirmedMove == "Rock") && (self.theirConfirmedMove == "Paper") {
                computedString = "\(self.theirConfirmedMove) beats \(self.myConfirmedMove)"
                self.opponentWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
            if (self.myConfirmedMove == "Rock") && (self.theirConfirmedMove == "Scissors") {
                computedString = "\(self.myConfirmedMove) beats \(self.theirConfirmedMove)"
                self.myWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
            if (self.myConfirmedMove == "Scissors") && (self.theirConfirmedMove == "Paper") {
                computedString = "\(self.myConfirmedMove) beats \(self.theirConfirmedMove)"
                self.myWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
            if (self.myConfirmedMove == "Scissors") && (self.theirConfirmedMove == "Rock") {
                computedString = "\(self.theirConfirmedMove) beats \(self.myConfirmedMove)"
                self.opponentWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
            if (self.myConfirmedMove == "Paper") && (self.theirConfirmedMove == "Scissors") {
                computedString = "\(self.theirConfirmedMove) beats \(self.myConfirmedMove)"
                self.opponentWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
            if (self.myConfirmedMove == "Paper") && (self.theirConfirmedMove == "Rock") {
                computedString = "\(self.myConfirmedMove) beats \(self.theirConfirmedMove)"
                self.myWinsNumber += 1
                self.roundsPlayedNumber += 1
            }
        }
        return computedString
    }
    
}
