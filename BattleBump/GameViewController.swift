//
//  GameViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController,
                          MPCManagerProtocol,
                          UICollectionViewDataSource,
                          UICollectionViewDelegate {
    
    var mpcManager = MPCManager()
    var playersForNewGame = [Player]()
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var theirLastMoveLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var currentPlayGameLabel: UILabel!
    @IBOutlet weak var giantMoveLabel: UILabel!
    @IBOutlet weak var winsAndRoundsLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var gameMovesCollectionView: UICollectionView!
    
    var onGameFinished: ((MPCManager) -> Void)?
    var gameLogicManager: GameLogicManager!
    var currentGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mpcManager.managerDelegate = self
        currentGame = Game(players: playersForNewGame, state: .gameStart)
        gameLogicManager = GameLogicManager(moveset: currentGame.me.chosenMoveset!)
        configureViews()
    }
    
    func configureViews() {
        readyButton.layer.borderWidth = 1
        readyButton.layer.borderColor = UIColor.systemGray.cgColor
        readyButton.layer.cornerRadius = 5
        
        currentPlayGameLabel.text = "You are playing \(currentGame.opponent.name)"
        winsAndRoundsLabel.text = "- / -"
    }
    
    func roundBegin() {
        currentGame.currentState = .roundInProgress
        currentGame.me.selectedMove = nil
       
        DispatchQueue.main.async {
            self.readyButton.isUserInteractionEnabled = false
            self.readyButton.setTitle("", for: .normal)
            self.readyButton.alpha = 0.0

            self.gameMovesCollectionView.isUserInteractionEnabled = true
            
            self.theirLastMoveLabel.text = ""
            self.resultLabel.text = ""
            
            self.progressRing.alpha = 1.0;
            self.giantMoveLabel.alpha = 0.0;
            
            if let index = self.gameMovesCollectionView.indexPathsForSelectedItems?.first {
                self.gameMovesCollectionView.deselectItem(at: index, animated: false)
                self.gameMovesCollectionView.cellForItem(at: index)?.layer.borderWidth = 1
                self.gameMovesCollectionView.cellForItem(at: index)?.layer.borderColor = UIColor.systemGray.cgColor
            }
        
            self.progressRing.setProgress(value: 0.0, animationDuration: 5.0) {
                self.countdownEnded()
            }
        }
    }
    
    func countdownEnded() {
        if (currentGame.me.selectedMove == nil) {
            currentGame.me.selectedMove = gameLogicManager.pickRandomMove()
        }
        
        DispatchQueue.main.async {
            self.gameMovesCollectionView.isUserInteractionEnabled = false
            
            self.progressRing.alpha = 0.0
            self.progressRing.setProgress(value: 5.0, animationDuration: 0.1, completion: nil)
            self.giantMoveLabel.alpha = 1.0
            self.giantMoveLabel.text = self.currentGame.me.selectedMove?.moveEmoji
        }
        
        self.mpcManager.send(self.currentGame.me)
    }
    
    func roundEnded() {
        currentGame = gameLogicManager.generateResults(game: currentGame)
        
        print("Round Ended. My Wins are now: \(currentGame.myRoundWins). Opponent Wins are now: \(currentGame.opponentRoundWins)")
        
        if currentGame.myRoundWins == 3 || currentGame.opponentRoundWins == 3 {
            gameOver()
            currentGame.currentState = .gameEnd
        } else {
            currentGame.me.isReadyForNewRound = false
            currentGame.opponent.isReadyForNewRound = false
            currentGame.currentState = .roundEnd
            
            DispatchQueue.main.async {
                self.readyButton.isUserInteractionEnabled = true
                self.readyButton.setTitle("Ready?", for: .normal)
                self.readyButton.alpha = 1.0
                self.readyButton.setTitleColor(.systemBlue, for: .normal)
            
                if let oppoMove = self.currentGame.opponent.selectedMove?.moveName {
                    self.theirLastMoveLabel.text = "\(self.currentGame.opponent.name) last played: \(oppoMove)"
                }
                
                if let lastRound = self.currentGame.rounds.keys.sorted().last {
                    self.resultLabel.text = self.currentGame.rounds[lastRound]!["sentence"]
                    if self.currentGame.rounds[lastRound]!["winner"] == "TIE" {
                        self.resultLabel.backgroundColor = UIColor.white
                    } else if self.currentGame.rounds[lastRound]!["winner"] == self.currentGame.me.name {
                        self.resultLabel.backgroundColor = UIColor.systemGreen
                    } else {
                        self.resultLabel.backgroundColor = UIColor.systemRed
                    }
                }
                
                self.winsAndRoundsLabel.text = "\(self.currentGame.myRoundWins) wins / \(self.currentGame.rounds.count) rounds"
            }
        }
    }
    
    func gameOver() {
        let titleString = currentGame.myRoundWins == 3 ? "You Won!" : "\(currentGame.opponent.name) Won!"
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.mpcManager.mySession = nil
            
            // Pass mpcManager back to HomeVC with a completion func? (or delegate if wanted to do heavy-handed)
            self.onGameFinished?(self.mpcManager)
            
            self.currentGame = nil
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        currentGame.me.isReadyForNewRound = true
        
        sender.isUserInteractionEnabled = false
        sender.setTitle("Waiting for opponent...", for: .normal)
        sender.alpha = 0.5
        sender.setTitleColor(.gray, for: .normal)
        
        mpcManager.send(currentGame.me)
        if (currentGame.me.isReadyForNewRound == true && currentGame.opponent.isReadyForNewRound == true) {
            roundBegin()
        }
    }
    
    //MARK: - MPCManagerProtocol -
    
    func didChangeFoundPeers() {
        // not necessary during game
        return
    }
    
    func didConnectSuccessfullyToPeer() {
        // not necessary during game
        return
    }
    
    func receivedPlayerDataFromPeer(_ player: Player) {
        print("Received Player Update")
        currentGame.opponent = player //TODO: consider breaking out Player class into Move class and just send Move object
        
        switch currentGame.currentState {
        case .gameStart, .roundEnd:
            if currentGame.me.isReadyForNewRound && currentGame.opponent.isReadyForNewRound {
                roundBegin()
            }
        case .roundInProgress:
            if currentGame.opponent.selectedMove != nil {
                roundEnded()
            }
        case .gameEnd:
            print("Game ended but received player data..")
        case .none:
            print("Unexpected reception of player/game state")
        }
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        // tear down game vars / await new game / currentGame = nil etc.
        let alertController = UIAlertController(title: "Connection interrupted! ☹️", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.onGameFinished?(self.mpcManager)
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        // popVC?
    }
    
    // MARK: - UICollectionView -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = currentGame.me.chosenMoveset?.moveArray.count {
            return count
        } else {
            print("Unknown number of moves found for numberOfItemsInSection")
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameMove", for: indexPath) as! GameMoveCell
        cell.move = currentGame.me.chosenMoveset?.moveArray[indexPath.item]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.layer.cornerRadius = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            selectedCell.layer.borderWidth = 5
            selectedCell.layer.borderColor = UIColor.systemGreen.cgColor
        }
        currentGame.me.selectedMove = currentGame.me.chosenMoveset?.moveArray[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let deselectedCell = collectionView.cellForItem(at: indexPath) {
            deselectedCell.layer.borderWidth = 1
            deselectedCell.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
    
}
