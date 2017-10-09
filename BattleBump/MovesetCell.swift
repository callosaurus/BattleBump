//
//  MovesetCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-10-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class MovesetCell: UICollectionViewCell {
  
  @IBOutlet weak var movesetImageView: UIImageView!
  
  var moveset: Moveset! {
    didSet {
      configure()
    }
  }
  
  fileprivate func configure() {
  
    switch moveset.numberOfMoves {
    case 3 :
      movesetImageView.image = UIImage(named: "TriangleImage")
    case 5:
      movesetImageView.image = UIImage(named: "PentagonImage")
    case 7:
      movesetImageView.image = UIImage(named: "SeptagonImage")
    default:
      movesetImageView.image = UIImage(named: "TriangleImage")
    }
  }
  
}
