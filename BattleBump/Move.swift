//
//  Move.swift
//  BattleBump
//
//  Created by Callum Davies on 2020-10-20.
//  Copyright © 2020 Callum Davies & Dave Augerinos. All rights reserved.
//

import Foundation

struct Move: Codable {
    var moveName: String            // "Rock"
    var moveEmoji: String           // "👊"
    var moveVerbs: [String: String] // ["vsScissors": "crushes", "vsLizard": "crushes"]
    
//    init(name: String, emoji: String, verbs: [String: String] ) {
//        moveName = name
//        moveEmoji = emoji
//        moveVerbs = verbs
//    }
}
