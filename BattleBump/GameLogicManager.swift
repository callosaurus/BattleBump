//
//  GameLogicManager.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-04-29.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class GameLogicManager {
    
    // TODO: Update to arc4random the length of the Moveset movesArray and return appropriately
    func pickRandomMove() -> String {
        var randomMove = ""
        let i = Int.random(in: 0..<3)
        switch i {
        case 0:
            randomMove = "Rock"
        case 1:
            randomMove = "Paper"
        case 2:
            randomMove = "Scissors"
        default:
            break
        }
        return randomMove
    }
    
    // TODO: Update this to use Moveset dict of dict comparisons
    func generateResults(game: Game) -> Game {        
        let myMove = game.me.selectedMove
        let opponentMove = game.opponent.selectedMove
        
        let roundsPlayed = game.rounds.count
        
        if (myMove == opponentMove) {
            game.rounds["round\(roundsPlayed+1)"] = ["winner": "TIE", "sentence":"\(myMove) ties \(opponentMove)"]
        }
        else {
            if (myMove == "Rock") && (opponentMove == "Paper") {
                opponentWins(round: roundsPlayed, game: game)
            }
            if (myMove == "Rock") && (opponentMove == "Scissors") {
                iWin(round: roundsPlayed, game: game)
            }
            if (myMove == "Scissors") && (opponentMove == "Paper") {
                iWin(round: roundsPlayed, game: game)
            }
            if (myMove == "Scissors") && (opponentMove == "Rock") {
                opponentWins(round: roundsPlayed, game: game)
            }
            if (myMove == "Paper") && (opponentMove == "Scissors") {
                opponentWins(round: roundsPlayed, game: game)
            }
            if (myMove == "Paper") && (opponentMove == "Rock") {
                iWin(round: roundsPlayed, game: game)
            }
        }
        return game
    }
    
    func iWin(round:Int, game: Game) {
        game.myRoundWins += 1
        game.rounds["round\(round+1)"] = ["winner": "\(game.me.name)", "sentence":"\(game.me.selectedMove) beats \(game.opponent.selectedMove)"]
    }
    
    func opponentWins(round: Int, game: Game) {
        game.opponentRoundWins += 1
        game.rounds["round\(round+1)"] = ["winner": "\(game.opponent.name)", "sentence":"\(game.opponent.selectedMove) beats \(game.me.selectedMove)"]
    }
    
}
