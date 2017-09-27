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
  var movesetImageViewsArray = [UIImageView]()
  var movesetOne: Moveset?
  var movesetTwo: Moveset?
  var movesetThree: Moveset?
  var movesetArray = [Moveset]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    playerName = "Player"
    playerEmoji = "😎"
    
    playerNameTextField.delegate = self
    playerEmojiTextField.delegate = self
    
  
    
    movesetImageViewsArray = [imageViewOne, imageViewTwo, imageViewThree]
    
    loadUserDefaults()
    prepareTableView()
    setupMPCManager()
  }
  
  //    override func viewWillAppear(_ animated: Bool) {
  
  //        super.viewWillAppear(animated)
  //        tableView.reloadData()
  //    }
  
  //MARK: - IBActions -
  @IBAction func editButtonPressed(_ sender: UIButton) {
    //take current moveset selection and pass to MovesetViewController
  }
  
  @IBAction func hostButtonPressed(_ sender: UIButton) {
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
    
    if defaults.dictionaryRepresentation().keys.contains("One") {
      movesetOne = defaults.object(forKey: "One") as? Moveset
      movesetTwo = defaults.object(forKey: "Two") as? Moveset
      movesetThree = defaults.object(forKey: "Three") as? Moveset
    } else {
      movesetOne = Moveset(name: "Standard", numberOfMoves: 3, movesArray: ["Rock", "Paper", "Scissors"])
      movesetTwo = Moveset(name: "Weapon triangle", numberOfMoves: 3, movesArray: ["Sword", "Spear", "Axe"])
      movesetThree = Moveset(name: "Pokemon", numberOfMoves: 7, movesArray: ["Grass", "Fire", "Rock", "Psychic", "Fighting", "Flying", "Water"])
    }
    
    let movesetArray = [movesetOne, movesetTwo, movesetThree]
    
    var j = 0
    for i in movesetImageViewsArray {
      
      switch movesetArray[j]!.numberOfMoves {
      case 3 :
        i.image = UIImage(named: "TriangleImage")
      case 5:
        i.image = UIImage(named: "PentagonImage")
      case 7:
        i.image = UIImage(named: "SeptagonImage")
      default:
        i.image = UIImage(named: "TriangleImage")
      }
      
      i.backgroundColor = UIColor.white
      i.isUserInteractionEnabled = true
      
      j = j + 1
    }
    
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
