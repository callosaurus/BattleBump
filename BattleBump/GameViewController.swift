//
//  GameViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController, MPCManagerProtocol {
    var mpcManager = MPCManager()
    var playersForNewGame = [Player]()
    
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var rockLabel: UILabel!
    @IBOutlet weak var theirLastMoveLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var paperLabel: UILabel!
    @IBOutlet weak var scissorsLabel: UILabel!
    @IBOutlet weak var currentPlayGameLabel: UILabel!
    @IBOutlet weak var giantMoveLabel: UILabel!
    @IBOutlet weak var winsAndRoundsLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    var rockConfirmationIcon: UIImageView?
    var paperConfirmationIcon: UIImageView?
    var scissorsConfirmationIcon: UIImageView?
    
    let gameLogicManager = GameLogicManager()
    var currentGame: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mpcManager.managerDelegate = self
        currentGame = Game(name: "\(currentGame?.me.name) and \(currentGame?.opponent.name)'s game", players: playersForNewGame, state: .gameStart)
        configureViews()
    }
    
    func configureViews() {
        
        currentPlayGameLabel.text = "You are playing \(currentGame?.opponent.name)"
        winsAndRoundsLabel.text = "- / -"
        
        let confirmRock = UITapGestureRecognizer(target: self, action: #selector(didConfirmRock(_:)))
        rockLabel.addGestureRecognizer(confirmRock)
        
        let confirmPaper = UITapGestureRecognizer(target: self, action: #selector(didConfirmPaper(_:)))
        paperLabel.addGestureRecognizer(confirmPaper)
        
        let confirmScissors = UITapGestureRecognizer(target: self, action: #selector(didConfirmScissors(_:)))
        scissorsLabel.addGestureRecognizer(confirmScissors)
    }
    
    func roundBegin() {
        currentGame?.currentState = .roundInProgress
        
        DispatchQueue.main.async {
            self.readyButton.isUserInteractionEnabled = false
            self.readyButton.setTitle("", for: .normal)
            self.readyButton.alpha = 0.0
            
            self.rockLabel.isUserInteractionEnabled = true
            self.paperLabel.isUserInteractionEnabled = true
            self.scissorsLabel.isUserInteractionEnabled = true
            
            self.theirLastMoveLabel.text = ""
            self.resultLabel.text = ""
            
            self.rockConfirmationIcon?.alpha = 0.0;
            self.paperConfirmationIcon?.alpha = 0.0;
            self.scissorsConfirmationIcon?.alpha = 0.0;
            
            self.progressRing.alpha = 1.0;
            self.giantMoveLabel.alpha = 0.0;
            
            self.currentGame?.me.selectedMove = ""
        }
        
        progressRing.setProgress(value: 0.0, animationDuration: 5.0, completion: { () in
            self.countdownEnded()
        })
    }
    
    func countdownEnded() {
        
        if (currentGame?.me.selectedMove == "") {
            currentGame?.me.selectedMove = gameLogicManager.pickRandomMove()
            print("Randomly selected \(String(describing: currentGame?.me.selectedMove))!")
        }
        
        DispatchQueue.main.async {
            self.rockLabel.isUserInteractionEnabled = false
            self.paperLabel.isUserInteractionEnabled = false
            self.scissorsLabel.isUserInteractionEnabled = false
            
            self.progressRing.alpha = 0.0
            self.progressRing.setProgress(value: 5.0, animationDuration: 0.1, completion: nil)
            
            self.giantMoveLabel.alpha = 1.0
            
            switch (self.currentGame?.me.selectedMove) {
            case "Rock":
                self.giantMoveLabel.text = "👊🏽"
                break;
            case "Paper":
                self.giantMoveLabel.text = "✋🏽"
                break;
            case "Scissors":
                self.giantMoveLabel.text = "✌🏽"
                break;
            default:
                break;
            }
        }
        
        self.mpcManager.send(self.currentGame!.me)
    }
    
    func roundEnded() {
        currentGame = gameLogicManager.generateResults(game: currentGame!)
        
        if currentGame?.myRoundWins == 3 || currentGame?.opponentRoundWins == 3 {
            gameOver()
            currentGame?.currentState = .gameEnd
        } else {
            currentGame?.me.isReadyForNewRound = false
            currentGame?.opponent.isReadyForNewRound = false
            currentGame!.currentState = .roundEnd
            
            DispatchQueue.main.async {
                self.readyButton.isUserInteractionEnabled = true
                self.readyButton.setTitle("Ready?", for: .normal)
                self.readyButton.alpha = 1.0
                self.readyButton.setTitleColor(.blue, for: .normal)
                
                self.theirLastMoveLabel.text = "\(self.currentGame?.opponent.name) last played: \(self.currentGame?.opponent.selectedMove)"
                if let lastRound = self.currentGame?.rounds.keys.sorted().last {
                    self.resultLabel.text = self.currentGame!.rounds[lastRound]!["sentence"]
                }
                self.winsAndRoundsLabel.text = "\(self.currentGame!.myRoundWins) wins / \(self.currentGame!.rounds.count) rounds"
            }
        }
        
    }
    
    func gameOver() {
        var titleString = ""
        if (currentGame?.myRoundWins == 3) {
            titleString = "You Won!"
        } else {
            titleString = "\(currentGame?.opponent.name ?? "Opponent") Won!"
        }
        
        DispatchQueue.main.async {
            //TODO: "Play again? - OK or No" - Tear down game vars / await new game
            let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                self.mpcManager.mySession = nil
                self.currentGame = nil
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        currentGame?.me.isReadyForNewRound = true
        
        sender.isUserInteractionEnabled = false
        sender.setTitle("Waiting for opponent...", for: .normal)
        sender.alpha = 0.5
        sender.setTitleColor(.gray, for: .normal)
        
        mpcManager.send(currentGame!.me)
        if (currentGame?.me.isReadyForNewRound == true && currentGame?.opponent.isReadyForNewRound == true) {
            roundBegin()
        }
    }
    
    //MARK: - Confirmations -
    
    //TODO: Update with Collection View for larger-than-3 movesets
    @objc func didConfirmRock(_ sender: UITapGestureRecognizer) {
        
        if (rockConfirmationIcon == nil) {
            rockConfirmationIcon = UIImageView(frame: CGRect(x: rockLabel.bounds.origin.x, y: rockLabel.bounds.origin.y, width: rockLabel.bounds.size.width, height: rockLabel.bounds.size.height))
            rockConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            rockConfirmationIcon?.tintColor = UIColor.green
            rockLabel.addSubview(rockConfirmationIcon!)
        }
        
        rockConfirmationIcon?.alpha = 0.5
        paperConfirmationIcon?.alpha = 0.0
        scissorsConfirmationIcon?.alpha = 0.0
        
        currentGame?.me.selectedMove = "Rock"
    }
    
    @objc func didConfirmPaper(_ sender: UITapGestureRecognizer) {
        
        if (paperConfirmationIcon == nil) {
            paperConfirmationIcon = UIImageView(frame: CGRect(x: paperLabel.bounds.origin.x, y: paperLabel.bounds.origin.y, width: paperLabel.bounds.size.width, height: paperLabel.bounds.size.height))
            paperConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            paperConfirmationIcon?.tintColor = UIColor.green
            paperLabel.addSubview(paperConfirmationIcon!)
        }
        
        rockConfirmationIcon?.alpha = 0.0
        paperConfirmationIcon?.alpha = 0.5
        scissorsConfirmationIcon?.alpha = 0.0
        
        currentGame?.me.selectedMove = "Paper"
    }
    
    @objc func didConfirmScissors(_ sender: UITapGestureRecognizer) {
        
        if (scissorsConfirmationIcon == nil) {
            scissorsConfirmationIcon = UIImageView(frame: CGRect(x: scissorsLabel.bounds.origin.x, y: scissorsLabel.bounds.origin.y, width: scissorsLabel.bounds.size.width, height: scissorsLabel.bounds.size.height))
            scissorsConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            scissorsConfirmationIcon?.tintColor = UIColor.green
            scissorsLabel.addSubview(scissorsConfirmationIcon!)
        }
        
        rockConfirmationIcon?.alpha = 0.0
        paperConfirmationIcon?.alpha = 0.0
        scissorsConfirmationIcon?.alpha = 0.5
        
        currentGame?.me.selectedMove = "Scissors"
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
        currentGame?.opponent = player //TODO: more elegant way of diff'ing player update instead of just overriding?
        
        switch currentGame?.currentState {
        case .gameStart:
            if (currentGame?.me.isReadyForNewRound == true && currentGame?.opponent.isReadyForNewRound == true) {
                roundBegin()
            }
            /*
            else if (currentGame?.me.isReadyForNewRound == false && currentGame?.opponent.isReadyForNewRound == true) {
                print("Opponent is ready but I am not. Waiting...")
            } else if (currentGame?.me.isReadyForNewRound == true && currentGame?.opponent.isReadyForNewRound == false) {
                print("I am ready but opponent is not. Waiting...")
            }
            */
        case .roundInProgress:
            if currentGame?.opponent.selectedMove != "" {
                roundEnded()
            }
        case .roundEnd:
            if (currentGame?.me.isReadyForNewRound == true && currentGame?.opponent.isReadyForNewRound == true) {
                roundBegin()
            }
            /*
            else if (currentGame?.me.isReadyForNewRound == false && currentGame?.opponent.isReadyForNewRound == true) {
                print("Opponent is ready but I am not. Waiting...")
            } else if (currentGame?.me.isReadyForNewRound == true && currentGame?.opponent.isReadyForNewRound == false) {
                print("I am ready but opponent is not. Waiting...")
            }
            */
        case .gameEnd:
            print("Game ended but received player data..")
        default:
            print("Unexpected reception of player/game state")
        }
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        // tear down game vars / await new game / currentGame = nil etc.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Connection interrupted! ☹️", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                //TODO: Assign back managerDelegate to HomeViewController
            })
            
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
            // popVC?
        }
    }
    
}
