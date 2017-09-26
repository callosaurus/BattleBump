//
//  Host.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-08.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Host: NSObject {

    var hostPeerID: MCPeerID
    var name: String
    var emoji: String
//    let moveset: [String : [String: String]]
    
    init(hostPeerID: MCPeerID, emoji: String) {
        
        self.hostPeerID = hostPeerID
        self.name = hostPeerID.displayName
        self.emoji = emoji
        super.init()
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let hostPeerID = decoder.decodeObject(forKey:"hostPeerID") as? MCPeerID,
            let emoji = decoder.decodeObject(forKey:"emoji") as? String
            else { return nil }
        
        self.init(hostPeerID: hostPeerID, emoji: emoji)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.hostPeerID, forKey: "hostPeerID")
        aCoder.encode(self.emoji, forKey: "emoji")
    }
    
}
