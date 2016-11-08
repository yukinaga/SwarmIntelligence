//
//  ViewController.swift
//  GPUCalc1
//
//  Created by Yukinaga2 on 2016/10/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

import UIKit
import Metal
import SpriteKit

class ViewController: UIViewController {

    let nodeCount = 200
    var nodes:[Node] = []
    
    var metalController:MetalController!
    var spriteScene:SpriteScene!
    
    var displayLink:CADisplayLink!
    var lastTimeStamp:CFTimeInterval = 0
    
    var fishes:[Fish] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        
        for _ in 0..<nodeCount {
            let randX = Float(arc4random_uniform(UInt32(width)))
            let randY = Float(arc4random_uniform(UInt32(height)))
            let randVX = Float(arc4random_uniform(UInt32(100)))/100.0
            let randVY = Float(arc4random_uniform(UInt32(100)))/100.0
            let randAngle = Float(arc4random_uniform(UInt32(100)))/100.0 * Float(M_PI) * 2 - Float(M_PI)

            nodes.append(Node(positionX: randX, positionY: randY, velocityX: randVX, velocityY: randVY, angle: randAngle))
            let fish = Fish()
            fish.center = CGPoint(x: CGFloat(randX), y: height-CGFloat(randY))
            self.view.addSubview(fish)
            fishes.append(fish)
        }

//        nodes.append(Node(positionX: 100, positionY: 100, velocityX: 0, velocityY: 1.05, angle: 0))
//        nodes.append(Node(positionX: 145, positionY: 100, velocityX: 0, velocityY: 1.0, angle: 0))

        metalController = MetalController(nodes, width: width, height: height)
        
//        let view = self.view as! SKView
//        view.ignoresSiblingOrder = true
//        view.showsFPS = true
//        view.showsNodeCount = true
        
//        spriteScene = SpriteScene(size: view.frame.size)
//        spriteScene.setSprites(nodes: nodes)
//        spriteScene.scaleMode = .aspectFill
//        spriteScene.backgroundColor = .white
//        view.presentScene(spriteScene)
        
//        let fish1 = Fish()
//        fish1.center = CGPoint(x: 100, y: 100)
//        self.view.addSubview(fish1)
//        fishes.append(fish1)
//        
//        let fish2 = Fish()
//        fish1.center = CGPoint(x: 120, y: 100)
//        self.view.addSubview(fish2)
//        fishes.append(fish2)
        
        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.update))
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func update() {
        
        if lastTimeStamp == 0 {
            lastTimeStamp = displayLink.timestamp
            return
        }
        
        let now = displayLink.timestamp
        let interval = now - lastTimeStamp
        lastTimeStamp = now
        
//        metalController.move(nodes: &nodes, interval: Float(interval))
        metalController.move(nodes: nodes, interval: Float(interval)){( resultNodes:[Node]) -> Void in
            
            nodes = resultNodes
            for (i, fish) in fishes.enumerated() {
                fish.setNode(node: nodes[i], height: self.view.frame.size.height)
            }
//            spriteScene.rotate()
//            spriteScene.replaceSprites(nodes: nodes)
        }
//        print(nodes[0].angle)
//        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(nodes[0].angle))
    }
}

//各個体を表す構造体
struct Node
{
    var positionX: Float = 0
    var positionY: Float = 0
    var velocityX: Float = 0
    var velocityY: Float = 0
    var angle: Float = 0
}
