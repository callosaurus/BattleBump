//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, MPCJoiningProtocol, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerEmojiLabel: UILabel!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var playerEmojiTextField: UITextField!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var tableViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var mpcManager = MPCManager()
    var playerInviteesArray = [Invitee]()
    var playerName: String?
    var playerEmoji: String?
    var me: Invitee?
    var foundHostsArray = [Host]()
    lazy var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerName = "Player"
        playerEmoji = "😎"
        
        self.playerNameTextField.delegate = self
        self.playerEmojiTextField.delegate = self
        
        loadUserDefaults()
        prepareTableView()
        setupMPCManager()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.tableView.reloadData()
//    }
    
    //MARK: - IBActions -
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.mpcManager.advertiseToPeers(invitee: self.me!)
    
    }
    
    @IBAction func playerNameTextFieldDidEndEditing(_ sender: UITextField) {
        
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(sender.text, forKey: "playerName")
        self.playerNameTextField.resignFirstResponder()
    }
    
    @IBAction func playerEmojiTextFieldDidEndEditing(_ sender: UITextField) {
        
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        if ((sender.text?.containsOnlyEmoji)! && (sender.text?.isSingleEmoji)!) {
            let defaults = UserDefaults.standard
            defaults.set(sender.text, forKey: "playerEmoji")
        } else {
            let alert = UIAlertController(title: "One emoji at a time 💩", message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                sender.text = "🙃"
                self.playerEmojiTextField.resignFirstResponder()
            })
        
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    //MARK: - Functions -
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        if(defaults.dictionaryRepresentation().keys.contains("playerName")) {
            self.playerName = defaults.string(forKey: "playerName")
            self.playerEmoji = defaults.string(forKey:"playerEmoji")
        }
        self.playerNameLabel.text = "Name"
        self.playerEmojiLabel.text = "Emoji"
        self.playerNameTextField.text = playerName
        self.playerEmojiTextField.text = playerEmoji
        
        //eventually load movesets from userdefaults. display visually
        let imageViews = [imageViewOne, imageViewTwo, imageViewThree]
        for i in imageViews {
            i?.image = UIImage(named: "confirmationTick")
        }
 
    }
    
    func prepareTableView() {
        self.tableViewLabel.text = "Joinable Players"
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_ :)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func setupMPCManager() {
        self.mpcManager.joinDelegate = self
        
        let thisPlayer = Player(name: playerName!, emoji: playerEmoji!, move: "join")
        let thisGame = Game(name: "placeholderName", state: "join")
        self.me = Invitee(player: thisPlayer, game: thisGame)
        
        self.mpcManager.findPeers(invitee: self.me!)
    }
    
    func refresh(_ sender: UIRefreshControl) {
        self.mpcManager.findPeers(invitee: self.me!)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerNameTextField.resignFirstResponder()
        playerEmojiTextField.resignFirstResponder()
    }
    
    //MARK: - UITextFieldDelegate Methods -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playerNameTextField.resignFirstResponder()
        playerEmojiTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - MPCJoining Protocol Method -
    
    func didChangeFoundHosts() {
        self.foundHostsArray = self.mpcManager.foundHostsArray
        self.refreshControl.endRefreshing()

        self.tableView.reloadData()
        
    }
    
    func didConnectSuccessfully(to invitee: Invitee) {
        
        self.me!.game.state = "ready"
        invitee.game.state = "ready"
        
        self.playerInviteesArray.append(self.me!)
        self.playerInviteesArray.append(invitee)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }
    
    // MARK: - Navigation -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let gameVC = segue.destination as? GameViewController {
            gameVC.playerInviteesArray = self.playerInviteesArray
            gameVC.mpcManager = self.mpcManager
            
        }
    }
    
    // MARK: - UITableView Methods -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHostPeerID = self.foundHostsArray[indexPath.row].hostPeerID
        self.mpcManager.joinPeer(peerID: selectedHostPeerID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! HostCell
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
