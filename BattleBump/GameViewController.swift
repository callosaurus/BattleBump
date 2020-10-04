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
    var rockConfirmationIcon: UIImageView?
    var paperConfirmationIcon: UIImageView?
    var scissorsConfirmationIcon: UIImageView?
    
    let gameLogicManager = GameLogicManager()
    var opponent: Player?
    var me: Player?
    var currentGame: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mpcManager.managerDelegate = self - Not needed b/c set during prepare(for segue:) ?
        
        me = playersForNewGame[0]
        opponent = playersForNewGame[1]
        currentGame = Game(name: "\(me!.name) and \(opponent!.name)'s game", players: playersForNewGame, state: .gameStart)
        configureViews()
    }
    
    func configureViews() {
        
        currentPlayGameLabel.text = "You are playing \(opponent!.name)"
        winsAndRoundsLabel.text = "- / -"
        
        let confirmRock = UITapGestureRecognizer(target: self, action: #selector(didConfirmRock(_:)))
        rockLabel.addGestureRecognizer(confirmRock)
        
        let confirmPaper = UITapGestureRecognizer(target: self, action: #selector(didConfirmPaper(_:)))
        paperLabel.addGestureRecognizer(confirmPaper)
        
        let confirmScissors = UITapGestureRecognizer(target: self, action: #selector(didConfirmScissors(_:)))
        scissorsLabel.addGestureRecognizer(confirmScissors)
    }
    
    func roundBegin() {
        // unlock moves for use
        // start countdown animation
        
        currentGame?.currentState = .roundBegin
        
        rockLabel.isUserInteractionEnabled = true
        paperLabel.isUserInteractionEnabled = true
        scissorsLabel.isUserInteractionEnabled = true
        
        theirLastMoveLabel.text = ""
        resultLabel.text = ""
        
        rockConfirmationIcon?.alpha = 0.0;
        paperConfirmationIcon?.alpha = 0.0;
        scissorsConfirmationIcon?.alpha = 0.0;
        
        progressRing.alpha = 1.0;
        giantMoveLabel.alpha = 0.0;
        
        me?.selectedMove = ""
        
        progressRing.setProgress(value: 0.0, animationDuration: 5.0, completion: { () in
            self.countdownEnded()
        })
    }
    
    func countdownEnded() {
        // lock moves
        // send selectedMove to other player
        
        if (me?.selectedMove == "") {
            me?.selectedMove = gameLogicManager.pickRandomMove()
//            print("Randomly picked a move!")
        }
        
        //reset UI
//        self.drawGiantMoveLabel()
        
        self.rockLabel.isUserInteractionEnabled = false
        self.paperLabel.isUserInteractionEnabled = false
        self.scissorsLabel.isUserInteractionEnabled = false
        
        self.progressRing.alpha = 0.0
        self.progressRing.setProgress(value: 5.0, animationDuration: 0.1, completion: nil)
        
        DispatchQueue.main.async {
            self.giantMoveLabel.alpha = 1.0
            
            switch (self.me?.selectedMove) {
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
        
        //set round over
        me?.isReadyForNewRound = false
        
        //notify opponent
        self.mpcManager.send(self.me!)
    }
    
    func roundEnded() {
        // update currentGame with things
        // await readyButtonPressed
        me?.isReadyForNewRound = false
        opponent?.isReadyForNewRound = false
        
        // check if gameOver should be triggered
//        let resultLabelString = gameLogicManager.generateResultsLabelWithMoves()
//
//        //Check if Game Over
//        if (gameLogicManager.myWinsNumber == 3 || gameLogicManager.opponentWinsNumber == 3) {
//            mpcManager.send(me!)
//            presentGameOverAlert()
//        } else {
//            mpcManager.send(me!)
//            me?.game.state = "ready"
//            opponent?.game.state = "ready"
//
//            //Update UI
//            DispatchQueue.main.async {
//
//                self.theirLastMoveLabel.text = String(format: "%@ played: %@", (self.opponent?.player.name)!, (self.opponent?.player.move)!)
//                self.resultLabel.text = resultLabelString
//                self.winsAndRoundsLabel.text = String(format: "%i / %i", self.gameLogicManager.myWinsNumber, self.gameLogicManager.roundsPlayedNumber)
//            }
//        }
            
        currentGame!.currentState = .roundEnd
        currentGame = gameLogicManager.generateResults(game: currentGame!)
    }
    
    func gameOver() {
        // calculate winner
        // display prompt
        var titleString = ""
        if (currentGame?.myRoundWins == 3) {
            titleString = "You Won!"
        } else {
            titleString = "\(opponent?.name ?? "Opponent") Won!"
        }
        
        DispatchQueue.main.async {
            //TODO: "Play again? - OK or No"
            let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                self.mpcManager.mySession = nil
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        // set me.isReadyForNewRound, send to other player
        // await them to send message back saying they're ready for new round
        
        me!.isReadyForNewRound = true
        mpcManager.send(me!)
    }
    
    //MARK: - Confirmations -
    
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
        
        me?.selectedMove = "Rock"
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
        
        me?.selectedMove = "Paper"
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
        
        me?.selectedMove = "Scissors"
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
        
        if me!.isReadyForNewRound && opponent!.isReadyForNewRound && currentGame?.currentState != .roundBegin  {
            // round ended, players both hit 'ready', received new opponent with .isReadyForNewRound = true
            guard player.isReadyForNewRound == true else {
                print("Unexpected opponent state received")
                return
            }
            
            opponent = player
            roundBegin()
            
        } else if me!.isReadyForNewRound == false && currentGame?.currentState == .roundBegin {
            // countdown ended but round hasn't ended yet
            opponent = player
            roundEnded()
        } else {
            print("Unexpected reception of player/game state")
        }
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        // tear down game vars / await new game / currentGame = nil etc.
        
        let alertController = UIAlertController(title: "Connection interrupted! ☹️", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
        // popVC?
    }
    
}
