//
//  HomeViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController,
                          MPCManagerProtocol,
                          MovesetEditingProtocol,
                          UITableViewDelegate,
                          UITableViewDataSource,
                          UITextFieldDelegate,
                          UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var tableViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movesetCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    var mpcManager = MPCManager()
    var playersForNewGame = [Player]()
    var playerName: String?
    var playerMovesets = [Moveset]()
    var movesetImages = [UIImage]()
    var me: Player!
    var foundPeersArray = [MCPeerID]()
    var foundPeersMovesetNames = [MCPeerID: String]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        if movesetCollectionView.indexPathsForSelectedItems != nil {
            disableInteractionWith(button: editButton)
            disableInteractionWith(button: hostButton)
        } else {
            enableInteractionWith(button: editButton)
            enableInteractionWith(button: hostButton)
        }
    }
    
    //MARK: - IBActions -
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        guard movesetCollectionView.indexPathsForSelectedItems != nil,
              selectedMoveset != nil else {
            fatalError("Edit button was pressed without a selectedMoveset")
        }
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        guard movesetCollectionView.indexPathsForSelectedItems != nil,
              selectedMoveset != nil,
              let movesetName = selectedMoveset?.movesetName else {
            return
        }
        me.isHost = true
        me.chosenMoveset = selectedMoveset
        mpcManager.advertiseToPeers(movesetName: movesetName)
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
    
    func enableInteractionWith(button: UIButton) {
        button.isUserInteractionEnabled = true
        button.alpha = 1.0
    }
    
    func disableInteractionWith(button: UIButton) {
        button.isUserInteractionEnabled = false
        button.alpha = 0.5
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        if(defaults.dictionaryRepresentation().keys.contains("playerName")) {
            playerName = defaults.string(forKey: "playerName")
        } else {
            playerName = "Player"
        }
        
        playerNameTextField.text = playerName
        me = Player(name: playerName!)
        
        if let loadedMovesets = defaults.object(forKey: "playerMovesets") as? Data {
            let decoder = JSONDecoder()
            if let movesets = try? decoder.decode([Moveset].self, from: loadedMovesets) {
                playerMovesets = movesets
            }
            print("Movesets loaded from defaults")
            
            movesetImages = ["movesetImage1","movesetImage2","movesetImage3"].map({ getSavedImage(named:$0)! })
        } else {
            let rock = Move(moveName: "Rock", moveEmoji: "👊", moveVerbs: ["Scissors": "crushes"])
            let paper = Move(moveName: "Paper", moveEmoji: "✋", moveVerbs: ["Rock": "wraps around"])
            let scissors = Move(moveName: "Scissors", moveEmoji: "✌️", moveVerbs: ["Paper": "cuts"])
            let standardRPSMoveset = Moveset(moves: [rock, paper, scissors], name: "Standard RPS")
            playerMovesets.append(contentsOf: repeatElement(standardRPSMoveset, count: 3))
            
            if let img1 = UIImage(named: "Circled 1"),
               let img2 = UIImage(named: "Circled 2"),
               let img3 = UIImage(named: "Circled 3") {
                movesetImages.append(img1)
                saveImage(image: img1, filename: "movesetImage1")
                movesetImages.append(img2)
                saveImage(image: img2, filename: "movesetImage2")
                movesetImages.append(img3)
                saveImage(image: img3, filename: "movesetImage3")
            }
            print("Movesets NOT loaded from defaults")
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
        if me.isHost == false {
            me.chosenMoveset = player.chosenMoveset
        }
        mpcManager.stopAdvertisingToPeers()
        guard me.chosenMoveset != nil else {
            fatalError("chosenMoveset is not in sync between me and player")
        }
        startNewGame(with: player)
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        return
    }
    
    func didChangeFoundPeers() {
        foundPeersArray = mpcManager.foundPeersArray
        foundPeersMovesetNames = mpcManager.foundPeersMovesetNames
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func startNewGame(with player: Player) {
        playersForNewGame = [me, player]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }
    
    func gameEnded() {
        foundPeersArray = []
        foundPeersMovesetNames.removeAll()
        tableView.reloadData()
        mpcManager.findPeers()
    }
    
    // MARK: - MovesetEditingProtocol -
    func movesetEditingEndedWith(moveset: Moveset, screenshot: UIImage) {
        guard let selectedIndex = movesetCollectionView.indexPathsForSelectedItems?.first else {
            return
        }
        playerMovesets[selectedIndex.item] = moveset
        movesetImages[selectedIndex.item] = screenshot
        
        let encoder = JSONEncoder()
        if let encodedMovesets = try? encoder.encode(playerMovesets) {
            let defaults = UserDefaults.standard
            defaults.set(encodedMovesets, forKey: "playerMovesets")
        }
        saveImage(image: screenshot, filename: "movesetImage\(Int(selectedIndex.item+1))")
        
        movesetCollectionView.deselectItem(at: selectedIndex, animated: false)
        disableInteractionWith(button: editButton)
        disableInteractionWith(button: hostButton)
        movesetCollectionView.reloadData()
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
                self.gameEnded()
            }
            gameVC.playersForNewGame = playersForNewGame
        } else if segue.identifier == "edit" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! MovesetViewController
            targetController.editingDelegate = self
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
        cell.movesetNameLabel.text = foundPeersMovesetNames[foundPeersArray[indexPath.row]]
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
        cell.movesetCellImageView.image = movesetImages[indexPath.item]
        cell.movesetCellImageView.contentMode = UIView.ContentMode.scaleAspectFit
        cell.movesetCellLabel.text = playerMovesets[indexPath.item].movesetName
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.systemGray.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: movesetCollectionView.frame.width / 3.2, height: movesetCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerMovesets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMoveset = playerMovesets[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? MovesetCell {
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.systemGray.cgColor
        }
        enableInteractionWith(button: editButton)
        enableInteractionWith(button: hostButton)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MovesetCell {
            cell.backgroundColor = UIColor.white
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
    
    func saveImage(image: UIImage, filename: String) {
        guard let data = image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as URL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent(filename))
            print("Saved Image to \(directory.appendingPathComponent(filename))")
            return
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
