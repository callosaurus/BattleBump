//
//  MovesetViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class MovesetViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var minusMovesButton: UIButton!
    @IBOutlet weak var plusMovesButton: UIButton!
    @IBOutlet weak var numberOfOutcomesLabel: UILabel!
    @IBOutlet weak var moveNameLabel: UILabel!
    @IBOutlet weak var moveEmojiLabel: UILabel!
    @IBOutlet weak var moveNameTextField: UITextField!
    @IBOutlet weak var moveEmojiTextField: UITextField!
    var currentNumberOfMoves: Int?
    let minimumNumberOfMoves = 3
    let maximumNumberOfMoves = 9
    // TODO: allow user to pick from 'sample' movesets like "Weapon triangle": ["Sword", "Spear", "Axe"] or "Pokemon": ["Grass", "Fire", "Rock", "Psychic", "Fighting", "Flying", "Water"] or "RPSLS 🖖"
    // TODO: emoji skin-color picker?
    
    var movesetInProgress: Moveset! {
        didSet {
            // make a copy for 'Undo All Changes'?
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveNameTextField.delegate = self
        moveEmojiTextField.delegate = self
        moveNameLabel.text = "Move Name:"
        moveEmojiLabel.text = "Move Emoji:"
        
        currentNumberOfMoves = movesetInProgress.moves.count
        if currentNumberOfMoves == minimumNumberOfMoves {
            disableInteractionWith(button: minusMovesButton)
        }
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
        
        moveNameTextField.isUserInteractionEnabled = false
        moveEmojiTextField.isUserInteractionEnabled = false
        let outcomesNum = (Float(self.movesetInProgress.moves.count) * 0.5).rounded(.down) * Float(self.movesetInProgress.moves.count)
        numberOfOutcomesLabel.text = "\(Int(outcomesNum)) possible outcomes"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveNameTextField.resignFirstResponder()
        moveEmojiTextField.resignFirstResponder()
    }
    
    //MARK: - IBActions -
    
    @IBAction func minus2MovesButtonPressed(_ sender: UIButton) {
        
        currentNumberOfMoves = currentNumberOfMoves! - 2
        if currentNumberOfMoves == minimumNumberOfMoves {
            disableInteractionWith(button: minusMovesButton)
        }
        enableInteractionWith(button: plusMovesButton)
        
        let last2Moves = Array(movesetInProgress.moves.suffix(2))
        movesetInProgress.moves.removeLast(2)
        movesetInProgress.moveEmojis?.removeValue(forKey: last2Moves[0])
        movesetInProgress.moveEmojis?.removeValue(forKey: last2Moves[1])
        
        redrawViews()
    }
    
    @IBAction func plus2MovesButtonPressed(_ sender: UIButton) {
        
        currentNumberOfMoves = currentNumberOfMoves! + 2
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
        enableInteractionWith(button: minusMovesButton)
        
        let currentMovesCount = self.movesetInProgress.moves.count
        movesetInProgress.moves.append("DefaultMove\(currentMovesCount+1)")
        movesetInProgress.moves.append("DefaultMove\(currentMovesCount+2)")
        movesetInProgress.moveEmojis!["DefaultMove\(currentMovesCount+1)"] = randomEmoji()
        movesetInProgress.moveEmojis!["DefaultMove\(currentMovesCount+2)"] = randomEmoji()
        
        redrawViews()
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
    
    @IBAction func moveNameTextFieldDidEndEditing(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        movesetInProgress.moves[indexPath!.item] = sender.text ?? "DefaultMove\(indexPath!.item)"
        
        moveNameTextField.resignFirstResponder()
        collectionView.reloadData()
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    @IBAction func moveEmojiTextFieldDidEndEditing(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else {
            return
        }
        
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let item = movesetInProgress.moves[indexPath!.item]
        movesetInProgress.moveEmojis!.updateValue(sender.text ?? "⛔️", forKey: item)
        
        moveEmojiTextField.resignFirstResponder()
        collectionView.reloadData()
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    // MARK: - Helper -
    
    func redrawViews() {
        DispatchQueue.main.async {
            
            self.collectionView.indexPathsForSelectedItems?.forEach({ self.collectionView.deselectItem(at: $0, animated: false) })
            
            if let selectedIndexes = self.collectionView.indexPathsForSelectedItems {
                print("Index Paths currently selected: \(selectedIndexes)")
            }
            
            self.collectionView.reloadData()
            let outcomesNum = (Float(self.movesetInProgress.moves.count) * 0.5).rounded(.down) * Float(self.movesetInProgress.moves.count)
            self.numberOfOutcomesLabel.text = "\(Int(outcomesNum)) possible outcomes"
        }
    }
    
    func randomEmoji() -> String {
        let range = 0x1F300...0x1F3F0
        let index = Int(arc4random_uniform(UInt32(range.count)))
        let ord = range.lowerBound + index
        guard let scalar = UnicodeScalar(ord) else { return "❓" }
        return String(scalar)
    }
    
    func enableInteractionWith(button: UIButton) {
        DispatchQueue.main.async() {
            button.isUserInteractionEnabled = true
            button.alpha = 1.0
            button.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    func disableInteractionWith(button: UIButton) {
        DispatchQueue.main.async() {
            button.isUserInteractionEnabled = false
            button.alpha = 0.5
            button.setTitleColor(.gray, for: .normal)
        }
    }
    
    // MARK: - UICollectionView -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movesetInProgress.moves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "circle", for: indexPath) as! CircularCollectionViewCell
        let thisMove = movesetInProgress.moves[indexPath.item]
        if let emoji = movesetInProgress.moveEmojis![thisMove] {
            cell.circleLabel.text = "\(emoji)"
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.systemBlue.cgColor
            cell.layer.cornerRadius = 10.0
        }
        return cell
 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexes = self.collectionView.indexPathsForSelectedItems {
            print("didSelectItem. New index paths currently selected: \(selectedIndexes)")
        }
        let selectedMove = movesetInProgress.moves[indexPath.item]
        if let emoji = movesetInProgress.moveEmojis![selectedMove] {
            DispatchQueue.main.async {
                self.moveNameTextField.text = "\(selectedMove)"
                self.moveEmojiTextField.text = "\(emoji)"
                self.moveNameTextField.isUserInteractionEnabled = true
                self.moveEmojiTextField.isUserInteractionEnabled = true
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        if let selectedIndexes = self.collectionView.indexPathsForSelectedItems {
//            print("didDeselectItem. New index paths currently selected: \(selectedIndexes)")
//        }
//    }
    
    //MARK: - UITextFieldDelegate Methods -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        moveNameTextField.resignFirstResponder()
        moveEmojiTextField.resignFirstResponder()
        return true
    }
}
