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

    let nodeCount = 10000
    
    var device: MTLDevice!
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //初期化
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        let ml2Func = defaultLibrary.makeFunction(name: "addAndSubtract")!
        computePipelineState = try! device.makeComputePipelineState(function: ml2Func)
    }
    
    @IBAction func calculate(sender: AnyObject)
    {
        //入力データ
        var inputData:[(Float32 ,Float32)] = []
        for _ in 0..<inputDataCount {
            inputData.append((1, 2))
        }
        
        //所要時間の測定開始
        let startingDate = Date()

        //コマンドバッファとエンコーダの作成と設定
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        //入力バッファの作成と設定
        let inputDataBuffer = device.makeBuffer(bytes: inputData, length: inputData.byteLength, options: [])
        computeCommandEncoder.setBuffer(inputDataBuffer, offset: 0, at: 0)
        
        //カウント
        var count = UInt32(inputDataCount)
        let countBuffer = device.makeBuffer(bytes: &count, length: MemoryLayout.size(ofValue: count), options: [])
        computeCommandEncoder.setBuffer(countBuffer, offset: 0, at: 1)
        
        //個体
        var node = Node(positionX: 1, positionY: 2, velocityX: 3, velocityY: 4)
        let nodeBuffer = device.makeBuffer(bytes: &node, length: MemoryLayout.size(ofValue: node), options: [])
        computeCommandEncoder.setBuffer(nodeBuffer, offset: 0, at: 4)
        
        //配列
        var sampleArray = [Float]()
        for i in 0..<10000 {
            sampleArray.append(Float(i))
        }
        let sampleArrayBuffer = device.makeBuffer(bytes: sampleArray, length: sampleArray.byteLength, options: [])
        computeCommandEncoder.setBuffer(sampleArrayBuffer, offset: 0, at: 3)
        
        //出力バッファの作成と設定
        let outputData = [(Float32, Float32)](repeating: (0, 0), count: inputData.count)
        let outputDataBuffer = device.makeBuffer(bytes: outputData, length: outputData.byteLength, options: [])
        computeCommandEncoder.setBuffer(outputDataBuffer, offset: 0, at: 2)
        
        //スレッドグループの数、スレッドグループ内のスレッドの数を設定。これにより並列で実行される演算数が決定される
        let width = 64
        let threadsPerGroup = MTLSize(width: width, height: 1, depth: 1)
        let numThreadgroups = MTLSize(width: (inputData.count + width - 1) / width, height: 1, depth: 1)
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        //エンコーダーからのコマンドは終了
        computeCommandEncoder.endEncoding()

        //コマンドバッファを実行し、完了するまで待機
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        //結果をresultDataに格納
        let data = Data(bytesNoCopy: outputDataBuffer.contents(), count: outputData.byteLength, deallocator: .none)
        var resultData = [(Float32, Float32)](repeating: (1, 1), count: outputData.count)
        resultData = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<(Float32, Float32)>(start: $0, count: data.count/MemoryLayout<(Float32, Float32)>.size))
        }
 
        //結果の表示
//        print(resultData)
        print("[Time] \(Date().timeIntervalSince(startingDate))")
        print("[Input data] Count: \(inputData.count), First value: \(inputData.first!), Last value: \(inputData.last!)")
        print("[Result data] Count: \(resultData.count), First value: \(resultData.first!), Last value: \(resultData.last!)")
    }

}

//配列要素のバイト数を取得
private extension Array {
    var byteLength: Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}

//各個体を表す構造体
struct Node
{
    var positionX: Float = 0
    var positionY: Float = 0
    var velocityX: Float = 0
    var velocityY: Float = 0
}
