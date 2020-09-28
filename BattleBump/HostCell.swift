//
//  HostCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class HostCell: UITableViewCell {

    @IBOutlet weak var playerNameLabel: UILabel!
    
    var host: Player! {
        didSet {
            configure()
        }
    }
    
    fileprivate func configure() {
        playerNameLabel.text = self.host.name
    }

}
