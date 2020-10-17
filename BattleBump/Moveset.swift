//
//  Moveset.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

class Moveset: Codable {
    
    var movesetName: String                                     // "Standard RPS"
    var moves: [String] //TODO: replace with var moves: [Move]  // ["Rock", "Paper", "Scissors"]
    var movesAndVerbsDictionary: [String: [String: String]]?    // ["Rock": ["vsScissors": "crushes"],"Paper": ["vsRock": "wraps around"],"Scissors": ["vsPaper": "cuts"]]
    
    var moveEmojis : [String: String]?    // ["Rock": <Image/Emoji>,"Paper": <Image/Emoji>,"Scissors": <Image/Emoji>] -- TODO: Allow images? e.g. picture of a hand in an orientation (but Image doesn't conform to Codable out of the box etc)
    
    init(name: String, moveNamesArray: [String], movesAndVerbs: [String: [String: String]], emojisDict: [String: String]) {
        movesetName = name
        moves = moveNamesArray
        movesAndVerbsDictionary = movesAndVerbs
        moveEmojis = emojisDict
    }
    
}

