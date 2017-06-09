//
//  Host.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-08.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit

class Host: NSObject {

    let name: String
    let emoji: String
//    let moveset: [String : [String: String]]
    
    init(name: String, emoji: String) {
        
        self.name = name
        self.emoji = emoji
        super.init()
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let name = decoder.decodeObject(forKey:"name") as? String,
            let emoji = decoder.decodeObject(forKey:"emoji") as? String
            else { return nil }
        
        self.init(name: name, emoji: emoji)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.emoji, forKey: "emoji")
    }
    
}
