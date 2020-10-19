//
//  CircularCollectionViewCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2020-10-12.
//  Copyright © 2020 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var circleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = isSelected ? 5 : 1
        }
    }
}
