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
    
    private var nodeCountBuffer: MTLBuffer!
    private var widthBuffer: MTLBuffer!
    private var heightBuffer: MTLBuffer!
    private var outBuffer: MTLBuffer!

    let nodeCount:UInt32
        
    init(_ nodes:[Node], width:CGFloat, height:CGFloat) {
        var count = UInt32(nodes.count)
        self.nodeCount = count
        
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        let ml2Func = defaultLibrary.makeFunction(name: "move")!
        computePipelineState = try! device.makeComputePipelineState(function: ml2Func)
        
        let threadWidth = 64
        threadsPerThreadgroup = MTLSize(width: threadWidth, height: 1, depth: 1)
        threadgroupsCount = MTLSize(width: (Int(nodeCount) + threadWidth - 1) / threadWidth, height: 1, depth: 1)
        
        nodeCountBuffer = device.makeBuffer(bytes: &count, length: MemoryLayout.size(ofValue: count), options: [])
        var wdth = Float(width)
        widthBuffer = device.makeBuffer(bytes: &wdth, length: MemoryLayout.size(ofValue: wdth), options: [])
        var hght = Float(height)
        heightBuffer = device.makeBuffer(bytes: &hght, length: MemoryLayout.size(ofValue: hght), options: [])
        outBuffer = device.makeBuffer(bytes: nodes, length: nodes.byteLength, options: [])
    }
    
    func move( nodes:[Node], interval:Float, callBack:([Node]) -> Void) {
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        let inBuffer = device.makeBuffer(bytes: nodes, length: nodes.byteLength, options: [])
        var itvl = Float32(interval)
        let intervalBuffer = device.makeBuffer(bytes: &itvl, length: MemoryLayout.size(ofValue: itvl), options: [])
        
        computeCommandEncoder.setBuffer(inBuffer, offset: 0, at: 0)
        computeCommandEncoder.setBuffer(nodeCountBuffer, offset: 0, at: 1)
        computeCommandEncoder.setBuffer(intervalBuffer, offset: 0, at: 2)
        computeCommandEncoder.setBuffer(widthBuffer, offset: 0, at: 3)
        computeCommandEncoder.setBuffer(heightBuffer, offset: 0, at: 4)
        computeCommandEncoder.setBuffer(outBuffer, offset: 0, at: 5)
        
        computeCommandEncoder.dispatchThreadgroups(threadgroupsCount, threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let data = Data(bytesNoCopy: outBuffer.contents(), count: nodes.byteLength, deallocator: .none)
        var resultNodes = [Node](repeating: Node(positionX: 0, positionY: 0, velocityX: 0, velocityY: 0, angle: 0), count: nodes.count)
        resultNodes = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Node>(start: $0, count: data.count/MemoryLayout<Node>.size))
        }
//        print(resultNodes)
        
        callBack(resultNodes)

//        nodes = data.withUnsafeBytes {
//            Array(UnsafeBufferPointer<Node>(start: $0, count: data.count/MemoryLayout<Node>.size))
//        }
//        nodes.removeAll()
//        nodes.append(contentsOf: resultData)
        

        
    }

}

private extension Array {
    var byteLength: Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}
