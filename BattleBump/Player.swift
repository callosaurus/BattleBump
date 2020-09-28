//
//  Player.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Player: NSCoding, Equatable {
    
    let name: String
    var selectedMove: String
    var isReadyForNewRound: Bool
    var isHost: Bool
    let peerID: MCPeerID
//    var chosenMoveset: Moveset
//    var playerImage
    
    init(name: String, peerID: MCPeerID) {
        self.name = name
        self.peerID = peerID
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name && lhs.peerID == rhs.peerID
    }
    
    func encode(with coder: NSCoder) {
        <#code#>
    }

    required init?(coder: NSCoder) {
        <#code#>
    }

//    init(name: String, emoji:String, move: String) {
//        self.name = name
//        self.move = move
//        super.init()
//    }
//
//    // MARK: NSCoding
//
//    required convenience init?(coder decoder: NSCoder) {
//
//        guard let name = decoder.decodeObject(forKey: "name") as? String,
//            let move = decoder.decodeObject(forKey: "move") as? String
//            else { return nil }
//
//        self.init(name: name, emoji: emoji, move: move)
//    }
//
//    func encode(with aCoder: NSCoder) {
//
//        aCoder.encode(self.name, forKey: "name")
//        aCoder.encode(self.move, forKey: "move")
//    }
}
