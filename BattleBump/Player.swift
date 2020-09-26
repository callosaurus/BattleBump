//
//  Player.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class Player: NSObject, NSCoding {

    @objc let name: String
    @objc let emoji: String
    @objc var move: String

    @objc init(name: String, emoji:String, move: String) {
        
        self.name = name
        self.emoji = emoji
        self.move = move
        super.init()
    }
   
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let name = decoder.decodeObject(forKey: "name") as? String,
            let emoji = decoder.decodeObject(forKey: "emoji") as? String,
            let move = decoder.decodeObject(forKey: "move") as? String
            else { return nil }
        
        self.init(name: name, emoji: emoji, move: move)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.emoji, forKey: "emoji")
        aCoder.encode(self.move, forKey: "move")
    }
}
