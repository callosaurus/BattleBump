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
    
    playerNameTextField.delegate = self
    playerEmojiTextField.delegate = self
    
    loadUserDefaults()
    prepareTableView()
    setupMPCManager()
  }
  
  //    override func viewWillAppear(_ animated: Bool) {
  //        super.viewWillAppear(animated)
  //        tableView.reloadData()
  //    }
  
  //MARK: - IBActions -
  
  @IBAction func startButtonPressed(_ sender: UIButton) {
    mpcManager.advertiseToPeers(invitee: me!)
    
  }
  
  @IBAction func playerNameTextFieldDidEndEditing(_ sender: UITextField) {
    
    guard let text = sender.text, !text.isEmpty else {
      return
    }
    
    let defaults = UserDefaults.standard
    defaults.set(sender.text, forKey: "playerName")
    playerNameTextField.resignFirstResponder()
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
      playerName = defaults.string(forKey: "playerName")
      playerEmoji = defaults.string(forKey:"playerEmoji")
    }
    playerNameLabel.text = "Name"
    playerEmojiLabel.text = "Emoji"
    playerNameTextField.text = playerName
    playerEmojiTextField.text = playerEmoji
    
    //eventually load movesets from userdefaults. display visually
    //        let imageViews = [imageViewOne, imageViewTwo, imageViewThree]
    //        for i in imageViews {
    //            i?.image = UIImage(named: "confirmationTick")
    //        }
    
    imageViewOne.image = UIImage(named: "PentagonImage")
    imageViewOne.backgroundColor = UIColor.white
    imageViewTwo.image = UIImage(named: "TriangleImage")
    imageViewTwo.backgroundColor = UIColor.white
    imageViewThree.image = UIImage(named: "SeptagonImage")
    imageViewThree.backgroundColor = UIColor.white
  }
  
  func prepareTableView() {
    tableViewLabel.text = "Joinable Players"
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh(_ :)), for: UIControlEvents.valueChanged)
    tableView.addSubview(refreshControl)
  }
  
  func setupMPCManager() {
    mpcManager.joinDelegate = self
    
    let thisPlayer = Player(name: playerName!, emoji: playerEmoji!, move: "join")
    let thisGame = Game(name: "placeholderName", state: "join")
    me = Invitee(player: thisPlayer, game: thisGame)
    
    mpcManager.findPeers(invitee: me!)
  }
  
  func refresh(_ sender: UIRefreshControl) {
    mpcManager.findPeers(invitee: me!)
    
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
    foundHostsArray = mpcManager.foundHostsArray
    refreshControl.endRefreshing()
    
    tableView.reloadData()
    
  }
  
  func didConnectSuccessfully(to invitee: Invitee) {
    
    me!.game.state = "ready"
    invitee.game.state = "ready"
    
    playerInviteesArray.append(me!)
    playerInviteesArray.append(invitee)
    
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "startGame", sender: self)
    }
  }
  
  // MARK: - Navigation -
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let gameVC = segue.destination as? GameViewController {
      gameVC.playerInviteesArray = playerInviteesArray
      gameVC.mpcManager = mpcManager
    }
  }
  
  // MARK: - UITableView Methods -
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedHostPeerID = foundHostsArray[indexPath.row].hostPeerID
    mpcManager.joinPeer(peerID: selectedHostPeerID)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! HostCell
    cell.playerNameLabel.text = foundHostsArray[indexPath.row].name
    cell.emojiLabel.text = foundHostsArray[indexPath.row].emoji
    //        cell.movesetName.text = foundHostsArray[indexPath.row].moveset["name"]
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return foundHostsArray.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
}
