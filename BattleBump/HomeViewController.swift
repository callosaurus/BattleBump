//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, BBNetworkManagerProtocol {
    
    
    @IBOutlet weak var playerNameAndEmojiLabel: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    
    var invitees = [Invitee]()
    var networkManager = BBNetworkManager()
    var playerInviteesArray = [Invitee]()
    var me: Invitee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //load userdefaults for playerNameAndEmojiLabel
    }
    
    @IBAction func editPlayerNameEmojiButtonPressed(_ sender: UIButton) {
        // new 'editing' view over name
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        // start advertising peers
        // UI spinner or "Waiting for players..."
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        //  change button text to "refres"
        //  browse for peers
        //  when found, add to tableview below
    }
    
    
    // MARK: - NetworkManager Protocol Method -
    
    func receivedInviteeMessage(_ invitee: Invitee) {
        if invitees.count == 0 {
            invitees.append(invitee)
        }
        else {
            for myInvitee: Invitee in invitees {
                if !(myInvitee.player.name == invitee.player.name) {
                    invitees.append(invitee)
                }
            }
        }
        
//        OperationQueue.main.addOperation {() -> Void in
//            connectedToLabel.text = invitee.player.name
//            inviteeCollectionView.reloadData()
//        }
        
    }
    
     // MARK: - Navigation -
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     var bbGameVC = BBGameViewController()
     bbGameVC.playerInviteesArray = self.playerInviteesArray as! NSMutableArray
     bbGameVC.networkManager = self.networkManager
     bbGameVC = segue.destination as! BBGameViewController
     }
    
}
