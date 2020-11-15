//
//  GameMoveCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2020-11-14.
//  Copyright © 2020 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class GameMoveCell: UICollectionViewCell {
    
    @IBOutlet weak var moveNameLabel: UILabel!
    @IBOutlet weak var moveEmojiLabel: UILabel!
    
    var move: Move? {
        didSet {
            moveNameLabel.text = move?.moveName
            moveNameLabel.textAlignment = .center
            moveEmojiLabel.text = move?.moveEmoji
            moveEmojiLabel.textAlignment = .center
        }
    }
    
}
