//
//  Moveset.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

class Moveset: Codable {
    
    var movesetName: String                                 // "Standard RPS"
    var numberOfMoves: Int                                  //  3
    var moveNamesArray: [String]                                //  ["Rock", "Paper", "Scissors"]
    var winningVerbDictionary: [String: [String: String]]?   // ["Rock": ["vsScissors": "crushes"], "Paper": ["vsRock": "wraps around"], "Scissors": ["vsPaper": "cuts"]]
    //TODO: include moveImages/moveEmojis
    
    init(name: String, numberOfMoves: Int, movesArray: [String]) {
        movesetName = name
        self.numberOfMoves = numberOfMoves
        self.moveNamesArray = movesArray
    }
    
}

