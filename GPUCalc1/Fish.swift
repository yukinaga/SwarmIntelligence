//
//  Fish.swift
//  SwarmIntelligence
//
//  Created by Yukinaga2 on 2016/11/07.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

import UIKit

class Fish: UIImageView {

    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        self.image = UIImage(named: "fish.png")
    }
    
    func  setNode(node:Node, height:CGFloat) {
        self.center = CGPoint(x: CGFloat(node.positionX), y: height - CGFloat(node.positionY))
        self.transform =  CGAffineTransform(rotationAngle: CGFloat(node.angle))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
