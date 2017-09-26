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
  var currentNumberOfMoves: Int?
  let minimumNumberOfMoves = 3
  let maximumNumberOfMoves = 9
  
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadUserDefaults()
//    drawMovesetDiagram()
    
  }
  
  func loadUserDefaults() {
    
  }
  
  func drawMovesetDiagram(number: Int) {
    
    var svgImageView = SVGImageView()
    
    switch number {
    case 3:
      svgImageView = SVGImageView(svgSource: "Triangle")
    case 5:
      svgImageView = SVGImageView(svgSource: "Pentagon")
    case 7:
      svgImageView = SVGImageView(svgSource: "Septagon")
    case 9:
      svgImageView = SVGImageView(svgSource: "Nonagon")
    default:
      svgImageView = SVGImageView(svgSource: "Triangle")
    }
    
    movesetView = svgImageView
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let position = touch.location(in: self.movesetView)
      print(position.x)
      print(position.y)
    }
  }
  
}
