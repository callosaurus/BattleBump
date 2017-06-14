//
//  Moveset.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

struct Moveset {
  var movesetName = "Basic RPS"
  var numberOfMoves = 3
  var movesArray = ["Rock", "Paper", "Scissors"]
  var winningVerbDictionary = ["Rock": ["vsScissors": "crushes"],
                                       "Paper": ["vsRock": "wraps around"],
                                       "Scissors": ["vsPaper": "cuts"]]
  
  init(name: String, numberOfMoves: Int, movesArray: [String]) {
    self.movesetName = name
    self.numberOfMoves = numberOfMoves
    self.movesArray = movesArray
  }
  
}

