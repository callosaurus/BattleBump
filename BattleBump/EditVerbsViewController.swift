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
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  //MARK: - IBActions -
  
  @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
  }

  //MARK: - Tableview methods -
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    return cell
  }
  
}
