//
//  Game.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class Game {

    var name: String { "\(me.name) and \(opponent.name)'s game" }
//    var players: [Player]
    let me: Player
    var myRoundWins: Int
    var opponent: Player
    var opponentRoundWins: Int
    var rounds = [String: [String: String]]()   // ["round1":{ "winner":"Callum","sentence": "Rock beats Scissors"},
                                                //  "round2": {"winner":"Dave",...]
    
    enum State: String, Codable {
        case gameStart
        case roundInProgress
        case roundEnd
        case gameEnd
        case none
    }
    var currentState: State
    
    // var numberOfRounds: Int
    // var movesetInUse: Moveset
    
    init(players:[Player], state: State) {
        self.me = players[0]
        self.opponent = players[1]
        self.currentState = .gameStart
        self.myRoundWins = 0
        self.opponentRoundWins = 0
    }
    
}
