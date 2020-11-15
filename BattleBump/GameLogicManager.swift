//
//  GameLogicManager.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-04-29.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class GameLogicManager {
    
    var movesetInUse: Moveset!
    
    init(moveset: Moveset) {
        movesetInUse = moveset
    }
    
    func pickRandomMove() -> Move {
        return movesetInUse.moveArray.randomElement()!
    }
    
    func generateResults(game: Game) -> Game {        
        guard let myMove = game.me.selectedMove, let opponentMove = game.opponent.selectedMove else {
            fatalError("Tried to generateResults but there was an error with moves")
        }
        let roundsPlayed = game.rounds.count
        let myMoveName = myMove.moveName
        let opponentMoveName = opponentMove.moveName
        
        if myMoveName == opponentMoveName {
            game.rounds["round\(roundsPlayed+1)"] = ["winner": "TIE", "sentence":"\(myMoveName) ties \(opponentMoveName)"]
        } else {
            if myMove.moveVerbs[opponentMoveName] != nil {
                game.myRoundWins += 1
                if let winningVerb = myMove.moveVerbs[opponentMoveName] {
                    let winningSentence = myMoveName + " " + winningVerb + " " + opponentMoveName
                    print("Winning sentence is \(winningSentence)")
                    game.rounds["round\(roundsPlayed+1)"] = ["winner": "\(game.me.name)", "sentence":winningSentence]
                }
            } else {
                game.opponentRoundWins += 1
                if let winningVerb = opponentMove.moveVerbs[myMoveName] {
                    let winningSentence = opponentMoveName + " " + winningVerb + " " + myMoveName
                    print("Winning sentence is \(winningSentence)")
                    game.rounds["round\(roundsPlayed+1)"] = ["winner": "\(game.opponent.name)", "sentence":winningSentence]
                }
            }
        }
        
        return game
    }
}
