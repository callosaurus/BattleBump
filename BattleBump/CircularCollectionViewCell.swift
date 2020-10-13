//
//  CircularCollectionViewCell.swift
//  BattleBump
//
//  Created by Callum Davies on 2020-10-12.
//  Copyright © 2020 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleLabel: UILabel!
    
    
    //    let titleLabel: UILabel
//
//    override init(frame: CGRect) {
//        titleLabel = {
//            let label = UILabel(frame: .zero)
//            label.textAlignment = .center
//            label.textColor = .white
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//        super.init(frame: frame)
//
//        backgroundView = {
//            let view = CircleView(frame: .zero)
//            view.backgroundColor = .lightGray
//            return view
//        }()
//
//        contentView.addSubview(titleLabel)
//        titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 4.0).isActive = true
//        titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -4.0).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init()
//        //        fatalError("init(coder:) has not been implemented")
//    }
}

//class CircleView: UICollectionReusableView {
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layer.cornerRadius = bounds.width / 2.0
//    }
//}
