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
    
    private var device: MTLDevice!
    private var defaultLibrary: MTLLibrary!
    private var commandQueue: MTLCommandQueue!
    private var computePipelineState: MTLComputePipelineState!
    
    private var threadsPerThreadgroup:MTLSize!
    private var threadgroupsCount:MTLSize!
    
    private var outBuffer: MTLBuffer!
    private var nodeCountBuffer: MTLBuffer!
    
    let nodeCount:Int
    
    init(_ nodes:[Node]) {
        var count = nodes.count
        self.nodeCount = count
        
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        let ml2Func = defaultLibrary.makeFunction(name: "move")!
        computePipelineState = try! device.makeComputePipelineState(function: ml2Func)
        
        let width = 64
        threadsPerThreadgroup = MTLSize(width: width, height: 1, depth: 1)
        threadgroupsCount = MTLSize(width: (nodeCount + width - 1) / width, height: 1, depth: 1)
        
        nodeCountBuffer = device.makeBuffer(bytes: &count, length: MemoryLayout.size(ofValue: count), options: [])
        outBuffer = device.makeBuffer(bytes: nodes, length: nodes.byteLength, options: [])
    }
    
    func move( nodes:inout [Node], interval:Float) {
        
        print("[Input data] Count: \(nodes.count), First value: \(nodes.first!), Last value: \(nodes.last!)")

        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        let inBuffer = device.makeBuffer(bytes: nodes, length: nodes.byteLength, options: [])
        print(inBuffer.contents())
        var itvl = interval
        let intervalBuffer = device.makeBuffer(bytes: &itvl, length: MemoryLayout.size(ofValue: itvl), options: [])
        
        computeCommandEncoder.setBuffer(inBuffer, offset: 0, at: 0)
        computeCommandEncoder.setBuffer(nodeCountBuffer, offset: 0, at: 1)
        computeCommandEncoder.setBuffer(intervalBuffer, offset: 0, at: 2)
        computeCommandEncoder.setBuffer(outBuffer, offset: 0, at: 3)
        
        computeCommandEncoder.dispatchThreadgroups(threadgroupsCount, threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let data = Data(bytesNoCopy: outBuffer.contents(), count: nodes.byteLength, deallocator: .none)
//        var resultData = [Node](repeating: Node, count: nodes.count)
        
        nodes = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Node>(start: $0, count: data.count/MemoryLayout<Node>.size))
        }
        
        //結果の表示
        print("[Result data] Count: \(nodes.count), First value: \(nodes.first!), Last value: \(nodes.last!)")
        
    }

}

private extension Array {
    var byteLength: Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}
