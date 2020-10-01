//
//  Game.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class Game {

    let name: String
//    var players: [Player]
    let me: Player
    var myRoundWins: Int
    let opponent: Player
    var opponentRoundWins: Int
    var rounds = [String: [String: String]]()   // ["round1":{ "winner":"Callum","sentence": "Rock beats Scissors"},
                                                //  "round2": {"winner":"Dave",...]
    
    enum State: String, Codable {
        case gameStart
        case roundBegin
        case roundEnd
        case gameEnd
    }
    var currentState: State
    
    // var numberOfRounds: Int
    // var movesetInUse: Moveset
    
    init(name: String, players:[Player], state: State) {
        self.name = name
        self.me = players[0]
        self.opponent = players[1]
        self.currentState = .gameStart
        self.myRoundWins = 0
        self.opponentRoundWins = 0
    }
    
}
