//
//  MovesetViewController.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-13.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import PocketSVG

class MovesetViewController: UIViewController {
  
  
  @IBOutlet weak var movesetView: UIView!
  @IBOutlet weak var numberOfOutcomesLabel: UILabel!
  
  
  //MARK: - IBActions -
  
  @IBAction func minus2MovesButtonPressed(_ sender: UIButton) {
    
  }
  @IBAction func plus2MovesButtonPressed(_ sender: UIButton) {
    
  }
  
  @IBAction func pickVerbsButtonPressed(_ sender: UIButton) {
    
  }
  
  @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
    
  }
  
  @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadUserDefaults()
    
    let svgImageView = SVGImageView(svgSource: "Pentagon")
    movesetView = svgImageView
    
  }
  
  func loadUserDefaults() {
    
  }
  
}
