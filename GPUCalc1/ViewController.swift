//
//  ViewController.swift
//  GPUCalc1
//
//  Created by Yukinaga2 on 2016/10/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    let nodeCount = 100
    var nodes:[Node] = []
    
    var metalController:MetalController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

//        for _ in 0..<nodeCount{
//            let node = Node(positionX: 1, positionY: 2, velocityX: 3, velocityY: 4, angle: 5)
//            nodes.append(node)
//        }
        nodes.append(Node(positionX: 10, positionY: 0, velocityX: 0, velocityY: 0, angle: 0))
        nodes.append(Node(positionX: 20, positionY: 0, velocityX: 0, velocityY: 0, angle: 0))
        print("[Input data] Count: \(nodes.count), First value: \(nodes.first!), Last value: \(nodes.last!)")

        metalController = MetalController(nodes, width: self.view.frame.size.width, height: self.view.frame.size.height)
        metalController.move(nodes: &nodes, interval: 1)
        //結果の表示
        print("[Result data] Count: \(nodes.count), First value: \(nodes.first!), Last value: \(nodes.last!)")
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
