//
//  SpriteScene.swift
//  SwarmIntelligence
//
//  Created by Yukinaga2 on 2016/11/06.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

import UIKit
import SpriteKit

class SpriteScene: SKScene {
    
    var fishes:[SKSpriteNode] = []
    
    func setSprites(nodes:[Node]) {
        for node in nodes{
            let fish = SKSpriteNode(imageNamed:"fish.png")
            fish.size = CGSize(width: 30, height: 30)
            fish.position = CGPoint(x: CGFloat(node.positionX), y: CGFloat(node.positionY))
            fish.zRotation = CGFloat(-node.angle)
            self.addChild(fish)
            fishes.append(fish)
        }
    }
    
    func replaceSprites(nodes:[Node]){
        for (i, node) in nodes.enumerated() {
            let fish = fishes[i]
            fish.position = CGPoint(x: CGFloat(node.positionX), y: CGFloat(node.positionY))
            fish.zRotation = CGFloat(-node.angle)
        }
    }
    
    func rotate() {
        for fish in fishes {
            fish.zRotation += 0.1
        }
    }
}
