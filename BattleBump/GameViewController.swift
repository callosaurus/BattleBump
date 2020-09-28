//
//  GameViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController, MPCGameplayProtocol {
    
    //  var playerInviteesArray = [Invitee]()
    var mpcManager = MPCManager()
//    var playersForNewGame = [Player]()
    
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
        mpcManager.gameplayDelegate = self
        
        configureViews()
    }
    
    func initializeNewGameWithPlayers(players: [Player]) {
        me = players[0]
        opponent = players[1]
        currentGame = Game(name: "\(me!.name) and \(opponent!.name)'s game", players: players, state: .gameStart)
    }
    
    func roundBegin() {
        // unlock moves for use
        // start countdown animation
    }
    
    func countdownEnded() {
        // lock moves
        // send selectedMove to other player
    }
    
    func updateRoundWinner() {
        // calculate round winner based on me.selectedMove and opponent.selectedMove
    }
    
    func roundEnded() {
        // update currentGame with things
        // await readyButtonPressed
    }
    
    func gameOver() {
        // calculate winner
        // display prompt
    }
    
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        // set me.isReadyForNewRound, send to other player
        // await them to send message back saying they're ready for new round
        
        if (me?.game.state == "ready" && opponent?.game.state == "ready") {
            
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
            
            if(gameLogicManager.myConfirmedMove != "") {
                gameLogicManager.myConfirmedMove = ""
            }
            
            progressRing.setProgress(value: 0.0, animationDuration: 5.0, completion: { () in
                
                //picks random move if user hasn't chosen one by end of timer
                if (self.gameLogicManager.myConfirmedMove == "") {
                    self.gameLogicManager.pickRandomMove()
                    print("Randomly picked \(self.gameLogicManager.myConfirmedMove)")
                }
                
                //reset UI
                self.drawGiantMoveLabel()
                
                self.rockLabel.isUserInteractionEnabled = false
                self.paperLabel.isUserInteractionEnabled = false
                self.scissorsLabel.isUserInteractionEnabled = false
                
                self.progressRing.alpha = 0.0
                self.progressRing.setProgress(value: 5.0, animationDuration: 0.1, completion: nil)
                
                //set round over
                self.me?.game.state = "roundOver"
                self.me?.player.move = self.gameLogicManager.myConfirmedMove
                
                //notify opponent
                self.mpcManager.send(self.me!)
                
            })
            
        }
    }
    
    func drawGiantMoveLabel() {
        DispatchQueue.main.async {
            self.giantMoveLabel.alpha = 1.0
            
            switch (self.gameLogicManager.myConfirmedMove) {
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
    }
    
    func configureViews() {
        
        currentPlayGameLabel.text = String(format: "You are playing %@", (opponent?.name)!)
        winsAndRoundsLabel.text = "- / -"
        
        let confirmRock = UITapGestureRecognizer(target: self, action: #selector(didConfirmRock(_:)))
        rockLabel.addGestureRecognizer(confirmRock)
        
        let confirmPaper = UITapGestureRecognizer(target: self, action: #selector(didConfirmPaper(_:)))
        paperLabel.addGestureRecognizer(confirmPaper)
        
        let confirmScissors = UITapGestureRecognizer(target: self, action: #selector(didConfirmScissors(_:)))
        scissorsLabel.addGestureRecognizer(confirmScissors)
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
        
        gameLogicManager.myConfirmedMove = "Rock"
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
        
        gameLogicManager.myConfirmedMove = "Paper"
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
        
        gameLogicManager.myConfirmedMove = "Scissors"
    }
    
    //MARK: - Round Over -
    
    func roundConclusion() {
        
        let resultLabelString = gameLogicManager.generateResultsLabelWithMoves()
        
        //Check if Game Over
        if (gameLogicManager.myWinsNumber == 3 || gameLogicManager.opponentWinsNumber == 3) {
            mpcManager.send(me!)
            presentGameOverAlert()
        } else {
            mpcManager.send(me!)
            me?.game.state = "ready"
            opponent?.game.state = "ready"
            
            //Update UI
            DispatchQueue.main.async {
                
                self.theirLastMoveLabel.text = String(format: "%@ played: %@", (self.opponent?.player.name)!, (self.opponent?.player.move)!)
                self.resultLabel.text = resultLabelString
                self.winsAndRoundsLabel.text = String(format: "%i / %i", self.gameLogicManager.myWinsNumber, self.gameLogicManager.roundsPlayedNumber)
            }
        }
    }
    
    func presentGameOverAlert() {
        var titleString = ""
        if (gameLogicManager.myWinsNumber == 3) {
            titleString = "You Won!"
        } else {
            titleString = String(format:"%@ Won!", (opponent?.player.name)!)
        }
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                self.mpcManager.mySession = nil
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
    }
    
    //MARK: - Networking -
    
    func receivedMessageFromPlayer(_ player: Player) {
        print("Received Invitee Message")
        opponent?.player.move = invitee.player.move;
        gameLogicManager.theirConfirmedMove = (opponent?.player.move)!;
        
        if(invitee.game.state == "roundOver" && me?.game.state == "roundOver") {
            
            roundConclusion()
        }
        
        // if me.isReadyForNewRound and opponent.isReadyForNewRound, roundBegin()
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        let alertController = UIAlertController(title: "Connection interrupted! ☹️", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
}
