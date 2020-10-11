//
//  MovesetViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class MovesetViewController: UIViewController {
    
    @IBOutlet weak var minusMovesButton: UIButton!
    @IBOutlet weak var plusMovesButton: UIButton!
    @IBOutlet weak var movesetImageView: UIImageView!
    @IBOutlet weak var numberOfOutcomesLabel: UILabel!
    var currentNumberOfMoves: Int?
    let minimumNumberOfMoves = 3
    let maximumNumberOfMoves = 9
    // TODO: allow user to pick from 'sample' movesets like "Weapon triangle": ["Sword", "Spear", "Axe"] or "Pokemon": ["Grass", "Fire", "Rock", "Psychic", "Fighting", "Flying", "Water"] or "RPSLS 🖖"
    // TODO: emoji skin-color picker?
    
    var movesetInProgress: Moveset! {
        didSet {
//            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        drawMovesetDiagram(number: movesetInProgress.movesAndVerbsDictionary!.keys.count)
        currentNumberOfMoves = movesetInProgress.movesAndVerbsDictionary!.keys.count
        
        if currentNumberOfMoves == minimumNumberOfMoves {
            disableInteractionWith(button: minusMovesButton)
        }
        
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
    }
    
    func drawMovesetDiagram(number: Int) {
        
        // Number of outcomes will always be "0.5n (rounded down) * n", maybe extract into func when 9-move cap is lifted
        switch number {
        case 3:
            movesetImageView.image = UIImage(named: "2-simplex")
            numberOfOutcomesLabel.text = "3 possible outcomes 🙂"
        case 5:
            movesetImageView.image = UIImage(named: "4-simplex")
            numberOfOutcomesLabel.text = "10 possible outcomes 🤔"
        case 7:
            movesetImageView.image = UIImage(named: "6-simplex")
            numberOfOutcomesLabel.text = "21 possible outcomes 😥"
        case 9:
            movesetImageView.image = UIImage(named: "8-simplex")
            numberOfOutcomesLabel.text = "36 possible outcomes 😳"
            
        default:
            movesetImageView.image = UIImage(named: "2-simplex")
        }
        
    }
    
    //MARK: - IBActions -
    
    @IBAction func minus2MovesButtonPressed(_ sender: UIButton) {
        
        currentNumberOfMoves = currentNumberOfMoves! - 2
        if currentNumberOfMoves == minimumNumberOfMoves {
            disableInteractionWith(button: minusMovesButton)
        }
        enableInteractionWith(button: plusMovesButton)
        drawMovesetDiagram(number: currentNumberOfMoves!)
    }
    
    @IBAction func plus2MovesButtonPressed(_ sender: UIButton) {
        
        currentNumberOfMoves = currentNumberOfMoves! + 2
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
        enableInteractionWith(button: minusMovesButton)
        drawMovesetDiagram(number: currentNumberOfMoves!)
    }
    
    func enableInteractionWith(button: UIButton) {
        button.isUserInteractionEnabled = true
        button.alpha = 1.0
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    func disableInteractionWith(button: UIButton) {
        button.isUserInteractionEnabled = false
        button.alpha = 0.5
        button.setTitleColor(.gray, for: .normal)
    }
    
    @IBAction func pickVerbsButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "pickVerbs", sender: sender)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Ask the user if they're sure they want to exit
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // save
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self.movesetImageView)
            print(position.x)
            print(position.y)
        }
    }
    
}
