//
//  EditVerbsViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class EditVerbsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        return "[\(movesetInProgress.moveArray[section].moveName)/\(movesetInProgress.moveArray[section].moveEmoji)]"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
}
