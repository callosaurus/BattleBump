//
//  EditVerbsViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class EditVerbsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var verbsTableView: UITableView!
    
    var movesetInProgress: Moveset!
    var onFinishEditingVerbs: ((Moveset) -> Void)?
    
    //MARK: - IBActions -
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.onFinishEditingVerbs?(self.movesetInProgress)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Tableview methods -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movesetInProgress.moveArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(round(Double(movesetInProgress.moveArray.count/2)))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(movesetInProgress.moveArray[section].moveEmoji) \(movesetInProgress.moveArray[section].moveName)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verbCell", for: indexPath) as! VerbEditCell
        let sectionMove = movesetInProgress.moveArray[indexPath.section]
        print("Current section move: \(sectionMove)")
        let sectionMoveIndex = movesetInProgress.moveArray.firstIndex(where: { $0.moveName == sectionMove.moveName })
        let losingMove = movesetInProgress.moveArray[wrapping: sectionMoveIndex! - (indexPath.row+1)]
        cell.verbTextField.delegate = self
        
        let winningVerb = sectionMove.moveVerbs[losingMove.moveName]
        cell.configure(losingMove: losingMove, verb: winningVerb!)
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }

        if let cell = textField.superview?.superview as? VerbEditCell {
            if let senderPath = verbsTableView.indexPath(for: cell) {
                print("\(senderPath)")
                movesetInProgress.moveArray[senderPath.section].moveVerbs[cell.cellMove!.moveName] = textField.text
            }
        }
        verbsTableView.reloadData()
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
        self.view.endEditing(true)
        return false
    }
    
}
