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
  
  @IBOutlet weak var movesetImageView: UIImageView!
  @IBOutlet weak var numberOfOutcomesLabel: UILabel!
  var currentNumberOfMoves: Int?
  let minimumNumberOfMoves = 3
  let maximumNumberOfMoves = 9
  
  var movesetInProgress: Moveset! {
    didSet {
//      configure()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    configure()
  }
  
  func configure() {
    drawMovesetDiagram(number: movesetInProgress.numberOfMoves)
  }
  
  func drawMovesetDiagram(number: Int) {
    
    switch number {
    case 3:
      movesetImageView.image = UIImage(named: "TriangleImage")
    case 5:
      movesetImageView.image = UIImage(named: "PentagonImage")
    case 7:
      movesetImageView.image = UIImage(named: "SeptagonImage")
    case 9:
      movesetImageView.image = UIImage(named: "NonagonImage")
    default:
      movesetImageView.image = UIImage(named: "TriangleImage")
    }
    
  }
  
  //MARK: - IBActions -
  
  @IBAction func minus2MovesButtonPressed(_ sender: UIButton) {
    
    if currentNumberOfMoves == minimumNumberOfMoves {
      return
    }
    currentNumberOfMoves = currentNumberOfMoves! - 2
    drawMovesetDiagram(number: currentNumberOfMoves!)
  }
  
  @IBAction func plus2MovesButtonPressed(_ sender: UIButton) {
    
    if currentNumberOfMoves == maximumNumberOfMoves {
      return
    }
    currentNumberOfMoves = currentNumberOfMoves! + 2
    drawMovesetDiagram(number: currentNumberOfMoves!)
  }
  
  @IBAction func pickVerbsButtonPressed(_ sender: UIButton) {
    self.performSegue(withIdentifier: "pickVerbs", sender: sender)
  }
  
  @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
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
