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
        return ["Rock", "Paper", "Scissors"].randomElement() ?? ""
    }
    
    // TODO: Update this to use Moveset dict of dict comparisons
    func generateResults(game: Game) -> Game {        
        let roundsPlayed = game.rounds.count
        
        if let myMove = game.me.selectedMove, let opponentMove = game.opponent.selectedMove {
            if myMove == opponentMove {
                game.rounds["round\(roundsPlayed+1)"] = ["winner": "TIE", "sentence":"\(myMove) ties \(opponentMove)"]
            }
            else {
                if myMove == "Rock" && opponentMove == "Paper" {
                    opponentWins(round: roundsPlayed, game: game)
                }
                if myMove == "Rock" && opponentMove == "Scissors" {
                    iWin(round: roundsPlayed, game: game)
                }
                if myMove == "Scissors" && opponentMove == "Paper" {
                    iWin(round: roundsPlayed, game: game)
                }
                if myMove == "Scissors" && opponentMove == "Rock" {
                    opponentWins(round: roundsPlayed, game: game)
                }
                if myMove == "Paper" && opponentMove == "Scissors" {
                    opponentWins(round: roundsPlayed, game: game)
                }
                if myMove == "Paper" && opponentMove == "Rock" {
                    iWin(round: roundsPlayed, game: game)
                }
            }
            
        }
        
        return game
    }
    
    func iWin(round:Int, game: Game) {
        guard let move1 = game.me.selectedMove, let move2 = game.opponent.selectedMove else {
            print("Couldn't add to game rounds because selectedMoves are invalid")
            return
        }
        game.myRoundWins += 1
        game.rounds["round\(round+1)"] = ["winner": "\(game.me.name)", "sentence":"\(move1) beats \(move2)"]
    }
    
    func opponentWins(round: Int, game: Game) {
        guard let move1 = game.opponent.selectedMove, let move2 = game.me.selectedMove else {
            print("Couldn't add to game rounds because selectedMoves are invalid")
            return
        }
        game.opponentRoundWins += 1
        game.rounds["round\(round+1)"] = ["winner": "\(game.opponent.name)", "sentence":"\(move1) beats \(move2)"]
    }
    
}
