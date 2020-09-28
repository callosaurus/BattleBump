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
    var players: [Player]
    var rounds: [String: [String: Player]]  // ["round1": {"winner":"Callum"},"round2": {"winner":"Dave"),...]
    
    enum State {
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
        self.players = players
        self.currentState = state
//        super.init()
    }
    
//    // MARK: NSCoding
//
//    required convenience init?(coder decoder: NSCoder) {
//
//        guard let name = decoder.decodeObject(forKey: "name") as? String
//            let state = decoder.decodeObject(forKey: "state") as? String
//            else { return nil }
//
//        self.init(name: name)
//    }
//
//    func encode(with aCoder: NSCoder) {
//
//        aCoder.encode(self.name, forKey: "name")
//        aCoder.encode(self.state, forKey: "state")
//    }
}
