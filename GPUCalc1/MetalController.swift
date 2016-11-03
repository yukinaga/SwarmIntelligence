//
//  MetalController.swift
//  SwarmIntelligence
//
//  Created by Yukinaga2 on 2016/11/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

import UIKit
import Metal

class MetalController: NSObject {
    
    var device: MTLDevice!
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    
    let nodeCount:uint
    init(_ nodeCount:uint) {
        self.nodeCount = nodeCount
    }

}
