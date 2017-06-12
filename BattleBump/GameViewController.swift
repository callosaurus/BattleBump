//
//  GameViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-07.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController, MPCGameplayProtocol, BBNetworkManagerProtocol {
    
    var playerInviteesArray = [Invitee]()
    var networkManager = BBNetworkManager()
    var mpcManager = MPCManager()
    
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
    var opponent: Invitee?
    var me: Invitee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.me = self.playerInviteesArray[0]
        self.opponent = self.playerInviteesArray[1]
        self.mpcManager.gameplayDelegate = self

        configureViews()
    }
    
    
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        if (self.me?.game.state == "ready" && self.opponent?.game.state == "ready") {
            
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
            
            if(self.gameLogicManager.myConfirmedMove != "") {
                self.gameLogicManager.myConfirmedMove = ""
            }
            
            self.progressRing.setProgress(value: 0.0, animationDuration: 5.0, completion: { () in
                
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
            self.giantMoveLabel.font.withSize(175.0)
            
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
        
        self.currentPlayGameLabel.text = String(format: "You are playing %@", (self.opponent?.player.name)!)
        
        let confirmRock = UITapGestureRecognizer(target: self, action: #selector(didConfirmRock(_:)))
        self.rockLabel.addGestureRecognizer(confirmRock)
        
        let confirmPaper = UITapGestureRecognizer(target: self, action: #selector(didConfirmPaper(_:)))
        self.paperLabel.addGestureRecognizer(confirmPaper)
        
        let confirmScissors = UITapGestureRecognizer(target: self, action: #selector(didConfirmScissors(_:)))
        self.scissorsLabel.addGestureRecognizer(confirmScissors)
    }
    
    //MARK: - Confirmations -
    
    func didConfirmRock(_ sender: UITapGestureRecognizer) {
        
        if (self.rockConfirmationIcon == nil) {
            self.rockConfirmationIcon = UIImageView(frame: CGRect(x: self.rockLabel.bounds.origin.x, y: self.rockLabel.bounds.origin.y, width: self.rockLabel.bounds.size.width, height: self.rockLabel.bounds.size.height))
            self.rockConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            self.rockConfirmationIcon?.tintColor = UIColor.green
            self.rockLabel.addSubview(self.rockConfirmationIcon!)
        }
        
        self.rockConfirmationIcon?.alpha = 0.5
        self.paperConfirmationIcon?.alpha = 0.0
        self.scissorsConfirmationIcon?.alpha = 0.0
        
        self.gameLogicManager.myConfirmedMove = "Rock"
    }
    
    func didConfirmPaper(_ sender: UITapGestureRecognizer) {
        
        if (self.paperConfirmationIcon == nil) {
            self.paperConfirmationIcon = UIImageView(frame: CGRect(x: self.paperLabel.bounds.origin.x, y: self.paperLabel.bounds.origin.y, width: self.paperLabel.bounds.size.width, height: self.paperLabel.bounds.size.height))
            self.paperConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            self.paperConfirmationIcon?.tintColor = UIColor.green
            self.paperLabel.addSubview(self.paperConfirmationIcon!)
        }
        
        self.rockConfirmationIcon?.alpha = 0.0
        self.paperConfirmationIcon?.alpha = 0.5
        self.scissorsConfirmationIcon?.alpha = 0.0
        
        self.gameLogicManager.myConfirmedMove = "Paper"
    }
    
    func didConfirmScissors(_ sender: UITapGestureRecognizer) {
        
        if (self.scissorsConfirmationIcon == nil) {
            self.scissorsConfirmationIcon = UIImageView(frame: CGRect(x: self.scissorsLabel.bounds.origin.x, y: self.scissorsLabel.bounds.origin.y, width: self.scissorsLabel.bounds.size.width, height: self.scissorsLabel.bounds.size.height))
            self.scissorsConfirmationIcon?.image = UIImage(named: "confirmationTick")?.withRenderingMode(.alwaysTemplate)
            self.scissorsConfirmationIcon?.tintColor = UIColor.green
            self.scissorsLabel.addSubview(self.scissorsConfirmationIcon!)
        }
        
        self.rockConfirmationIcon?.alpha = 0.0
        self.paperConfirmationIcon?.alpha = 0.0
        self.scissorsConfirmationIcon?.alpha = 0.5
        
        self.gameLogicManager.myConfirmedMove = "Scissors"
    }
    
    //MARK: - Round Over -
    
    func roundConclusion() {
        
        let resultLabelString = self.gameLogicManager.generateResultsLabelWithMoves()
        
        //Check if Game Over
        if (self.gameLogicManager.myWinsNumber == 3 || self.gameLogicManager.opponentWinsNumber == 3) {
            self.mpcManager.send(self.me!)
            presentGameOverAlert()
        } else {
            self.mpcManager.send(self.me!)
            self.me?.game.state = "ready"
            self.opponent?.game.state = "ready"
            
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
        if (self.gameLogicManager.myWinsNumber == 3) {
            titleString = "You Won!"
        } else {
            titleString = String(format:"%@ Won!", (self.opponent?.player.name)!)
        }
        
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.mpcManager.mySession = nil
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
    
    //MARK: - Networking -
    
    func receivedInviteeMessage(_ invitee: Invitee) {
        print("Received Invitee Message")
        self.opponent?.player.move = invitee.player.move;
        self.gameLogicManager.theirConfirmedMove = (self.opponent?.player.move)!;
        
        if(invitee.game.state == "roundOver" && self.me?.game.state == "roundOver") {
            
            roundConclusion()
        }
    }
    
    func session(session: MCSession, wasInterruptedByState state: MCSessionState) {
        
        let alertController = UIAlertController(title: "Connection interrupted! ☹️", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
 
}
