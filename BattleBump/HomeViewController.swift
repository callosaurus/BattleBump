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
    @IBOutlet weak var movesetOneButton: UIButton!
    @IBOutlet weak var movesetTwoButton: UIButton!
    @IBOutlet weak var movesetThreeButton: UIButton!
    
    var mpcManager = MPCManager()
    var playersForNewGame = [Player]()
    var playerName: String?
    var me: Player!
    var foundPeersArray = [MCPeerID]()
    var connectedPlayersArray = [Player]()
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
        
        me = Player(name: playerName!)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moveCellIdentifier", for: indexPath) as! MovesetCell
        cell.moveset = movesetArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movesetArray.count
    }
    
}
