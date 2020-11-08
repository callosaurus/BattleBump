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
    var moveArrayCountHalved: Int?
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
        
        currentNumberOfMoves = movesetInProgress.moveArray.count
        moveArrayCountHalved = Int(round(Double(movesetInProgress.moveArray.count/2)))
        
        if currentNumberOfMoves == minimumNumberOfMoves {
            disableInteractionWith(button: minusMovesButton)
        }
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
        
        moveNameTextField.isUserInteractionEnabled = false
        moveEmojiTextField.isUserInteractionEnabled = false
        let outcomesNum = (Float(self.movesetInProgress.moveArray.count) * 0.5).rounded(.down) * Float(self.movesetInProgress.moveArray.count)
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
        
//        let last2Moves = Array(movesetInProgress.moveArray.suffix(2))
        movesetInProgress.moveArray.removeLast(2)
//        movesetInProgress.moveEmojis?.removeValue(forKey: last2Moves[0])
//        movesetInProgress.moveEmojis?.removeValue(forKey: last2Moves[1])
        
        moveArrayCountHalved = Int(round(Double(movesetInProgress.moveArray.count/2)))
        redrawViews()
    }
    
    @IBAction func plus2MovesButtonPressed(_ sender: UIButton) {
        
        currentNumberOfMoves = currentNumberOfMoves! + 2
        if currentNumberOfMoves == maximumNumberOfMoves {
            disableInteractionWith(button: plusMovesButton)
        }
        enableInteractionWith(button: minusMovesButton)
        
//        let currentMovesCount = movesetInProgress.moveArray.count
//        movesetInProgress.moves.append("DefaultMove\(currentMovesCount+1)")
//        movesetInProgress.moves.append("DefaultMove\(currentMovesCount+2)")
//        movesetInProgress.moveEmojis!["DefaultMove\(currentMovesCount+1)"] = randomEmoji()
//        movesetInProgress.moveEmojis!["DefaultMove\(currentMovesCount+2)"] = randomEmoji()
        let defaultMove = Move(moveName: "Default Move", moveEmoji: "❓", moveVerbs: ["vsDefault":"beats"])
//        movesetInProgress.moveArray.append(defaultMove)
        movesetInProgress.moveArray.append(contentsOf: repeatElement(defaultMove, count: 2))
        
        moveArrayCountHalved = Int(round(Double(movesetInProgress.moveArray.count/2)))
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
        guard let text = sender.text, !text.isEmpty, let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        
        movesetInProgress.moveArray[indexPath.item].moveName = text
        
        moveNameTextField.resignFirstResponder()
        collectionView.reloadData()
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        
        var newMoves = [String]()
        movesetInProgress.moveArray.forEach { move in
            newMoves.append(move.moveName)
        }
        print("Name TextField DidEndEditing. The move names are now: \(newMoves)")
    }
    
    @IBAction func moveEmojiTextFieldDidEndEditing(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty, let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        
        movesetInProgress.moveArray[indexPath.item].moveEmoji = text
        
        moveEmojiTextField.resignFirstResponder()
        collectionView.reloadData()
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        
        var newMoves = [String]()
        movesetInProgress.moveArray.forEach { move in
            newMoves.append(move.moveEmoji)
        }
        print("Emoji TextField DidEndEditing. The move emojis are now: \(newMoves)")
    }
    
    // MARK: - Helper -
    
    func redrawViews() {
            self.collectionView.indexPathsForSelectedItems?.forEach({ self.collectionView.deselectItem(at: $0, animated: false) })
            
            if let selectedIndexes = self.collectionView.indexPathsForSelectedItems {
                print("Index Paths currently selected: \(selectedIndexes)")
            }
            
            self.collectionView.reloadData()
            let outcomesNum = (Float(self.movesetInProgress.moveArray.count) * 0.5).rounded(.down) * Float(self.movesetInProgress.moveArray.count)
            self.numberOfOutcomesLabel.text = "\(Int(outcomesNum)) possible outcomes"
    }
    
//    func randomEmoji() -> String {
//        let range = 0x1F300...0x1F3F0
//        let index = Int(arc4random_uniform(UInt32(range.count)))
//        let ord = range.lowerBound + index
//        guard let scalar = UnicodeScalar(ord) else { return "❓" }
//        return String(scalar)
//    }
    
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
    
    // MARK: - UICollectionView -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movesetInProgress.moveArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "circle", for: indexPath) as! CircularCollectionViewCell
        //        let thisMove = movesetInProgress.moveArray[indexPath.item].moveEmoji
        //        if let emoji = movesetInProgress.moveEmojis![thisMove]
        let emoji = movesetInProgress.moveArray[indexPath.item].moveEmoji
        cell.circleLabel.text = emoji
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.systemBlue.cgColor
        cell.layer.cornerRadius = 10.0
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItem: \(indexPath.item)")
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        selectedCell.layer.borderColor = UIColor.systemBlue.cgColor
        selectedCell.layer.borderWidth = 4
        let selectedMove = movesetInProgress.moveArray[indexPath.item]
        moveNameTextField.text = selectedMove.moveName
        moveEmojiTextField.text = selectedMove.moveEmoji
        moveNameTextField.isUserInteractionEnabled = true
        moveEmojiTextField.isUserInteractionEnabled = true
        
        let indexes = Array(0..<movesetInProgress.moveArray.count) // [0, 1, 2, 3, 4, 5, 6]
        
        var winsAgainstIndexes = [Int]()
        var losesAgainstIndexes = [Int]()
        for i in 1...moveArrayCountHalved! {
            winsAgainstIndexes.append(indexes[wrapping: indexPath.item - i])
            losesAgainstIndexes.append(indexes[wrapping: indexPath.item + i])
        }
        print("losesAgainstIndexes: \(losesAgainstIndexes)") // [4, 5, 6]
        print("winsAgainstIndexes: \(winsAgainstIndexes)") // [2, 1, 0]
        
        var losesAgainstCells = [UICollectionViewCell]()
        losesAgainstIndexes.forEach { index in
            let indexpath = IndexPath(indexes: [0,index])
            let cell = collectionView.cellForItem(at: indexpath)
            losesAgainstCells.append(cell!)
        }
        losesAgainstCells.forEach { cell in
            cell.layer.borderColor = UIColor.systemRed.cgColor
            cell.layer.borderWidth = 4
            // TODO: draw arrows or other UI element TO selected cell FROM other cells that BEAT selected cell
        }
        
        var winsAgainstCells = [UICollectionViewCell]()
        winsAgainstIndexes.forEach { index in
            let indexpath = IndexPath(indexes: [0,index])
            let cell = collectionView.cellForItem(at: indexpath)
            winsAgainstCells.append(cell!)
        }
        winsAgainstCells.forEach { cell in
            cell.layer.borderColor = UIColor.systemGreen.cgColor
            cell.layer.borderWidth = 4
            // draw arrows or other UI element FROM selected cell TO other cells that are BEATEN by selected cell
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

//https://stackoverflow.com/questions/45397603/cleanest-way-to-wrap-array-index
extension Array {
    subscript (wrapping index: Int) -> Element {
        return self[(index % self.count + self.count) % self.count]
    }
}
