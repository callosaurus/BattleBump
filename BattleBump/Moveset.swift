//
//  Moveset.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

class Moveset: NSObject, NSCoding {
  
  var movesetName: String!                                 // "Standard RPS"
  var numberOfMoves: Int!                                  //  3
  var movesArray: [String]!                                //  ["Rock", "Paper", "Scissors"]
  var winningVerbDictionary: [String: [String: String]]?   // ["Rock": ["vsScissors": "crushes"], "Paper": ["vsRock": "wraps around"], "Scissors": ["vsPaper": "cuts"]]
  
  func encode(with aCoder: NSCoder) {
    
    aCoder.encode(movesetName, forKey: "movesetName")
    aCoder.encode(numberOfMoves, forKey: "numberOfMoves")
    aCoder.encode(movesArray, forKey: "movesArray")
    if let winningVerbDictionary = winningVerbDictionary { aCoder.encode(winningVerbDictionary, forKey: "winningVerbDictionary")}
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
    self.movesetName = aDecoder.decodeObject(forKey: "movesetName") as? String
    self.numberOfMoves = aDecoder.decodeObject(forKey: "numberOfMoves") as? Int
    self.movesArray = (aDecoder.decodeObject(forKey: "movesArray") as? [String])
  }
  
  convenience init(name: String, numberOfMoves: Int, movesArray: [String]) {
    self.init()
    self.movesetName = name
    self.numberOfMoves = numberOfMoves
    self.movesArray = movesArray
  }
  
}

