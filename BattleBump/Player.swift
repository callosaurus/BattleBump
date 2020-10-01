//
//  Player.swift
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Player: Codable {
    
    var name: String
    var selectedMove: String // TODO: change to use Moveset.swift etc
    var isReadyForNewRound: Bool
    var isHost: Bool
//    var chosenMoveset: Moveset
//    var playerImage
    
    init(name: String) {
        self.name = name
//        self.peerID = peerID --- NOT NEEDED now, wanted to make Player Codable easily without `extension MCPeerID: Codable`
        self.selectedMove = ""
        self.isHost = false
        self.isReadyForNewRound = false
    }
    
//    static func == (lhs: Player, rhs: Player) -> Bool {
//        return lhs.name == rhs.name //&& lhs.peerID == rhs.peerID
//    }

}
