//
//  Moveset.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

class Moveset: Codable {
    
    var moveArray: [Move]

    init(moves: [Move]) {
        moveArray = moves
    }
    
}

