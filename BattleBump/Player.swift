//
//  Player.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class Player: Codable {
    
    var name: String
    var selectedMove: String?
    //var selectedMove: Move?
    var isReadyForNewRound: Bool
    var isHost: Bool
    var chosenMoveset: Moveset?
    
    init(name: String) {
        self.name = name
        self.isHost = false
        self.isReadyForNewRound = false
    }

}
