//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, MPCJoiningProtocol, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var tableViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movesetOneButton: UIButton!
    @IBOutlet weak var movesetTwoButton: UIButton!
    @IBOutlet weak var movesetThreeButton: UIButton!
    
    var mpcManager = MPCManager()
    //  var playerInviteesArray = [Invitee]()
    var playersForNewGame = [Player]()
    var playerName: String?
    var me: Player!
    var foundPlayersArray = [Player]()
    lazy var refreshControl = UIRefreshControl()
    var movesetButtonArray = [UIButton]()
      var movesetOne: Moveset?
      var movesetTwo: Moveset?
      var movesetThree: Moveset?
      var selectedMoveset: Moveset?
      var movesetArray = [Moveset]()
      var selectedMovesetIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameTextField.delegate = self
        playerNameLabel.text = "Name: "
        
        loadUserDefaults()
        prepareTableView()
        setupMPCManager()
    }
    
    /*
     override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     tableView.reloadData()
     }
     */
    
    //MARK: - IBActions -
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        //take current moveset selection and pass to MovesetViewController
        if (selectedMoveset != nil) {
            self.performSegue(withIdentifier: "edit", sender: self)
        } else {
            return
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        mpcManager.advertiseToPeers(player: me!)
    }
    
    @IBAction func playerNameTextFieldDidEndEditing(_ sender: UITextField) {
        
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        //TODO: Disallow ':' character, as it's used as a Player.peerID delimiter
        
        playerName = sender.text
        let defaults = UserDefaults.standard
        defaults.set(sender.text, forKey: "playerName")
        playerNameTextField.resignFirstResponder()
    }
    
    //MARK: - Functions -
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        if(defaults.dictionaryRepresentation().keys.contains("playerName")) {
            playerName = defaults.string(forKey: "playerName")
        } else {
            playerName = "Player"
        }
        
        playerNameTextField.text = playerName
        
            if defaults.dictionaryRepresentation().keys.contains("One") {
              movesetOne = defaults.object(forKey: "One") as? Moveset
              movesetTwo = defaults.object(forKey: "Two") as? Moveset
              movesetThree = defaults.object(forKey: "Three") as? Moveset
            } else {
              movesetOne = Moveset(name: "Standard", numberOfMoves: 3, movesArray: ["Rock", "Paper", "Scissors"])
              movesetTwo = Moveset(name: "Weapon triangle", numberOfMoves: 3, movesArray: ["Sword", "Spear", "Axe"])
              movesetThree = Moveset(name: "Pokemon", numberOfMoves: 7, movesArray: ["Grass", "Fire", "Rock", "Psychic", "Fighting", "Flying", "Water"])
            }
        
            movesetArray = [movesetOne!, movesetTwo!, movesetThree!]
            movesetButtonArray = [movesetOneButton, movesetTwoButton, movesetThreeButton]
        
            var j = 0
            for button in movesetButtonArray {
        
                button.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        
              switch movesetArray[j].numberOfMoves {
              case 3 :
                button.setImage(UIImage(named: "2-simplex"), for: .normal)
              case 5:
                button.setImage(UIImage(named: "4-simplex"), for: .normal)
              case 7:
                button.setImage(UIImage(named: "6-simplex"), for: .normal)
              case 9:
                button.setImage(UIImage(named: "8-simplex"), for: .normal)
              default:
                button.setImage(UIImage(named: "2-simplex"), for: .normal)
              }
        
              button.backgroundColor = UIColor.white
              button.tintColor = UIColor.lightGray
              button.layer.borderColor = UIColor.lightGray.cgColor
              button.layer.cornerRadius = 10.0
              button.layer.borderWidth = 1.0
        
              j = j + 1
            }
        
    }
    
    func prepareTableView() {
        tableViewLabel.text = "Joinable Players"
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_ :)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func setupMPCManager() {
        mpcManager.joinDelegate = self
        
        // Append UIDevice to avoid user name collisions
        me = Player(name: playerName!, peerID: MCPeerID(displayName: "\(playerName!):\(UIDevice.current.name)"))
        
        //    let thisPlayer = Player(name: playerName!, emoji: playerEmoji!, move: "join")
        //    let thisGame = Game(name: "placeholderName", state: "join")
        //    me = Invitee(player: thisPlayer, game: thisGame)
        
        // TODO: Decide on UX choice between automatic browsing for others on viewDidLoad, or 'search for hosts' button
        mpcManager.findPeers(player: me!)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        mpcManager.findPeers(player: me!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerNameTextField.resignFirstResponder()
    }
    
    //
    @IBAction func movesetOneButtonPressed(_ sender: UIButton) {
        selectedMoveset = movesetOne
        selectedMovesetIndex = 0
    }
    
    @IBAction func movesetTwoButtonPressed(_ sender: UIButton) {
        selectedMoveset = movesetTwo
        selectedMovesetIndex = 1
    }
    
    @IBAction func movesetThreeButtonPressed(_ sender: UIButton) {
        selectedMoveset = movesetThree
        selectedMovesetIndex = 2
    }
    
    
    //MARK: - UITextFieldDelegate Methods -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playerNameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - MPCJoining Protocol Method -
    
    func didChangeFoundPlayers() {
        foundPlayersArray = mpcManager.foundPlayersArray
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func didConnectSuccessfully(to player: Player) {
        //    me!.game.state = "ready"
        //    invitee.game.state = "ready"
        //    playerInviteesArray.append(me!)
        //    playerInviteesArray.append(invitee)
        
        playersForNewGame = [me, player]
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }
    
    // MARK: - Navigation -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameViewController {
            gameVC.mpcManager = mpcManager
            gameVC.initializeNewGameWithPlayers(players: playersForNewGame)
        } else if segue.identifier == "edit" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! MovesetViewController
            targetController.movesetInProgress = selectedMoveset
        }
    }
    
    // MARK: - UITableView Methods -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlayerPeerID = foundPlayersArray[indexPath.row].peerID
        mpcManager.joinPeer(peerID: selectedPlayerPeerID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! HostCell
        cell.playerNameLabel.text = foundPlayersArray[indexPath.row].name
        /*
         after completing moveset picker, add movesetName label to HostCell
         cell.movesetName.text = foundHostsArray[indexPath.row].moveset["name"]
         */
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundPlayersArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UICollectionView Methods -
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moveCellIdentifier", for: indexPath) as! MovesetCell
        cell.moveset = movesetArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movesetArray.count
    }
    
}
