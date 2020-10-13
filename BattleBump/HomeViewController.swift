//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, MPCManagerProtocol, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var tableViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movesetCollectionView: UICollectionView!
    
    var mpcManager = MPCManager()
    var playersForNewGame = [Player]()
    var playerName: String?
    var playerMovesets = [Moveset]()
    var me: Player!
    var foundPeersArray = [MCPeerID]()
    var connectedPlayersArray = [Player]()
    lazy var refreshControl = UIRefreshControl()
    var selectedMoveset: Moveset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameTextField.delegate = self
        playerNameLabel.text = "Name: "
        
        loadUserDefaults()
        prepareTableView()
        movesetCollectionView.reloadData()
        setupMPCManager()
    }
    
    //MARK: - IBActions -
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        //take current moveset selection and pass to MovesetViewController
        guard selectedMoveset != nil else {
            print("Edit button was pressed without a selectedMoveset")
            return
        }
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        mpcManager.advertiseToPeers()
    }
    
    @IBAction func playerNameTextFieldDidEndEditing(_ sender: UITextField) {
        
        guard let text = sender.text, !text.isEmpty, playerName != sender.text else {
            return
        }
        
        playerName = text
        me.name = text
        let defaults = UserDefaults.standard
        defaults.set(text, forKey: "playerName")
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
        me = Player(name: playerName!)
        
        if defaults.dictionaryRepresentation().keys.contains("playerMovesets") {
            playerMovesets = defaults.object(forKey: "playerMovesets") as! [Moveset]
        } else {
            //TODO: Give the player more than the 3 basic 'RPS' movesets? e.g. Weapon triangle/Pokemon/Spock&Lizard RPS/umop versions?
            let standardMoves = ["Rock", "Paper", "Scissors"]
            let standardMoveVerbs = ["Rock": ["vs-Scissors": "crushes"],
                                 "Paper": ["vs-Rock": "wraps around"],
                                 "Scissors": ["vs-Paper": "cuts"]]
            let standardEmojis = ["Rock": "👊", "Paper": "✋", "Scissors": "✌️"]
            let standardRPSMoveset = Moveset(name: "Standard RPS", moveNamesArray: standardMoves, movesAndVerbs: standardMoveVerbs, emojisDict: standardEmojis)
            
            playerMovesets.append(contentsOf: repeatElement(standardRPSMoveset, count: 3))
        }
        print("Movesets loaded: \(playerMovesets.map({ $0.movesetName }))")
        
    }
    
    func prepareTableView() {
        tableViewLabel.text = "Joinable Players"
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_ :)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func setupMPCManager() {
        mpcManager.managerDelegate = self
        
        // TODO: Decide on UX choice between automatic browsing for others on viewDidLoad, or 'search for hosts' button
        mpcManager.findPeers()
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        mpcManager.findPeers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerNameTextField.resignFirstResponder()
    }
    
    //MARK: - UITextFieldDelegate Methods -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playerNameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - MPCManagerProtocol Method -
    
    func didConnectSuccessfullyToPeer() {
        mpcManager.send(me)
    }
    
    func receivedPlayerDataFromPeer(_ player: Player) {
        startNewGame(with: player)
        //TODO: include moveset reception from Host if necessary
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        return
    }
    
    func didChangeFoundPeers() {
        foundPeersArray = mpcManager.foundPeersArray
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    //    func didConnectSuccessfully() {
    //        mpcManager.send(me)
    //    }
    
    func startNewGame(with player: Player) {
        
        playersForNewGame = [me, player]
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }
    
    // MARK: - Navigation -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameViewController {
            gameVC.mpcManager = mpcManager
            
            gameVC.onGameFinished = { [weak self] mpcManager in
                guard let self = self else {
                    // we should never have lost reference to HomeVC but need to handle this
                    return
                }
                self.mpcManager = mpcManager
                self.mpcManager.managerDelegate = self
            }
            gameVC.playersForNewGame = playersForNewGame
        } else if segue.identifier == "edit" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! MovesetViewController
            targetController.movesetInProgress = selectedMoveset
        }
    }
    
    // MARK: - UITableView Methods -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeerID = foundPeersArray[indexPath.row]
        mpcManager.joinPeer(peerID: selectedPeerID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! HostCell
        cell.playerNameLabel.text = foundPeersArray[indexPath.row].displayName
        /*
         after completing moveset picker, add movesetName label to HostCell
         cell.movesetName.text = foundHostsArray[indexPath.row].moveset["name"]
         */
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundPeersArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UICollectionView Methods -
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moveset", for: indexPath) as! MovesetCell
        cell.moveset = playerMovesets[indexPath.item]
        cell.movesetCellImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerMovesets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMoveset = playerMovesets[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? MovesetCell {
            cell.backgroundColor = UIColor.green
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MovesetCell {
            cell.backgroundColor = UIColor.white
        }
    }
    
}
