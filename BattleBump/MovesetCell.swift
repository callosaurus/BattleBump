//
//  MovesetCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-10-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class MovesetCell: UICollectionViewCell {
    
    @IBOutlet weak var movesetCellImageView: UIImageView!
    @IBOutlet weak var movesetCellLabel: UILabel!
    
    var moveset: Moveset! {
        didSet {
            configure()
        }
    }
    
    fileprivate func configure() {
        switch moveset.movesAndVerbsDictionary!.keys.count {
        case 3:
            movesetCellImageView.image = UIImage(named: "2-simplex")
        case 5:
            movesetCellImageView.image = UIImage(named: "4-simplex")
        case 7:
            movesetCellImageView.image = UIImage(named: "6-simplex")
        case 9:
            movesetCellImageView.image = UIImage(named: "8-simplex")
        default:
            print("Unknown number of moves when configuring MovesetCell")
            movesetCellImageView.image = UIImage(named: "2-simplex")
        }
        
        movesetCellLabel.text = moveset.movesetName
    }
    
}
