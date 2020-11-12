//
//  VerbEditCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2020-11-11.
//  Copyright © 2020 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class VerbEditCell: UITableViewCell {
    
    @IBOutlet weak var verbTextField: UITextField!
    @IBOutlet weak var losingMoveLabel: UILabel!
    
    var move: Move! {
        didSet {
            losingMoveLabel.text = move.moveName
        }
    }
    
}
