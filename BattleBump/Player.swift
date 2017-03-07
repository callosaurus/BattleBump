//
//  Player.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit

class Player: NSObject {

    private let name: String
    private let emoji: String

    init(name: String, emoji:String) {
        
        self.name = name;
        self.emoji = emoji;
        super.init()
    }
}