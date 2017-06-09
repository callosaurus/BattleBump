//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, MPCJoiningProtocol, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var mpcManager = MPCManager()
    var playerInviteesArray = [Invitee]()
    var playerName : String?
    var playerEmoji : String?
    var me: Invitee?
    var foundHostsArray = [Host]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserDefaults()
        
        playerName = "testPlayer"
        playerEmoji = "😎"
        self.playerNameLabel.text = String(format: "%@ %@", self.playerName!, self.playerEmoji!)
        self.imageViewOne.image = UIImage(named: "confirmationTick")
        self.imageViewTwo.image = UIImage(named: "confirmationTick")
        self.imageViewThree.image = UIImage(named: "confirmationTick")

        self.mpcManager.joinDelegate = self
        
        let thisPlayer = Player(name: playerName!, emoji: playerEmoji!, move: "join")
        let thisGame = Game(name: "placeholderName", state: "join")
        self.me = Invitee(player: thisPlayer, game: thisGame)
        
        self.mpcManager.findPeers(invitee: self.me!)
    }
    
    //MARK: - IBActions -
    @IBAction func editPlayerNameEmojiButtonPressed(_ sender: UIButton) {
        // new 'editing' view over name
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.mpcManager.advertiseToPeers(invitee: self.me!)
        
//        self.state = "starting"
//        
//        let loadingView = UIView(frame: CGRect(x: Int(self.view.bounds.origin.x), y: Int(self.view.bounds.origin.y), width: Int(self.view.bounds.width/2), height: Int(self.view.bounds.height/2)))
//        loadingView.center = self.view.center
//        loadingView.backgroundColor = UIColor.lightGray
//        loadingView.tag = 1000
//        
//        let activityView = UIActivityIndicatorView(frame: loadingView.frame)
//        activityView.startAnimating()
//        
//        loadingView.addSubview(activityView)
//        
//        self.view.addSubview(loadingView)
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
//        self.mpcManager.findPeers(invitee: self.me!)
//        
//        self.state = "joining"
        
        //Loader.addLoaderTo(self.tableView)
        //  when found, add to tableview below
    }
    
    //MARK: - Functions
    func loadUserDefaults() {
        self.playerNameLabel.text = "Player😎"
        let defaults = UserDefaults.standard
        
        if(defaults.dictionaryRepresentation().keys.contains("playerName")) {
            self.playerName = defaults.string(forKey: "playerName")
            self.playerEmoji = defaults.string(forKey:"playerEmoji")
            self.playerNameLabel.text = String(format: "%@ %@", self.playerName!, self.playerEmoji!)
        }
    }
    
    // MARK: - MPCJoining Protocol Method -
    
    //update to remove received InviteeMessage
//    func receivedInviteeMessage(_ invitee: Invitee) {
//        
//        if self.playerInviteesArray.count == 0 {
//            self.playerInviteesArray.append(invitee)
//        }
//        
//        if (invitee.game.state == "join" && self.state == "starting") {
//            
//            let subViews = self.view.subviews
//            for subview in subViews{
//                if subview.tag == 1000 {
//                    subview.removeFromSuperview()
//                }
//            }
//            self.performSegue(withIdentifier: "startGame", sender: self)
//            
//        } else if (self.state == "joining") {
//            
//            if self.playerInviteesArray.count == 0 {
//                self.playerInviteesArray.append(invitee)
//            } else {
//                
//                for myInvitee: Invitee in self.playerInviteesArray {
//                    if (myInvitee.player.name != invitee.player.name) {
//                        self.playerInviteesArray.append(invitee)
//                    }
//                }
//            }
//            
//            OperationQueue.main.addOperation { () in
//                self.tableView.reloadData()
//            }
//        }
//    }
    
    func didChangeFoundHosts() {
        self.foundHostsArray = self.mpcManager.foundHostsArray
        self.tableView.reloadData()
    }
    
    func didConnectSuccessfully(to invitee: Invitee) {
        //do the thing
    }
    
    // MARK: - Navigation -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var bbGameVC = GameViewController()
        bbGameVC.playerInviteesArray = self.playerInviteesArray
        bbGameVC.mpcManager = self.mpcManager
        bbGameVC = segue.destination as! GameViewController
    }
    
    // MARK: - UITableView Methods -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHostPeerID = self.foundHostsArray[indexPath.row].hostPeerID
        self.mpcManager.joinPeer(peerID: selectedHostPeerID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! hostCell
        cell.playerNameLabel.text = foundHostsArray[indexPath.row].name
        cell.emojiLabel.text = foundHostsArray[indexPath.row].emoji
//        cell.movesetName.text = foundHostsArray[indexPath.row].moveset["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foundHostsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
