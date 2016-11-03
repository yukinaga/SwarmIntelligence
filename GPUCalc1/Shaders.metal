//
//  Shaders.metal
//  GPUCalc1
//
//  Created by Yukinaga2 on 2016/10/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Node
{
    float positionX;
    float positionY;
    float velocityX;
    float velocityY;
};

kernel void addAndSubtract(const device float2 *position [[ buffer(0) ]],
                           const device uint &count [[ buffer(1) ]],
                           device float2 *newVelocity [[ buffer(2) ]],
                           const device array<float, 10> &ary[[buffer(3)]],
                           const device Node &node [[buffer(4)]],
                           uint id [[ thread_position_in_grid ]])
{
    float sumX = 1.0f;
    float sumY = 1.0f;
    
    for (uint i=0; i<10000; i++){
//        if (i < 5000){
////            sumX += ary[i];
////            sumY += ary[i];
//        
            sumX += position[i].x;
            sumY += position[i].y;
//        }else{
//            sumX += position[id].y;
//            sumY += position[id].x;
//            
//        }
//        sumX += node.positionX;
//        sumY += node.positionY;
    }
//    float tt = float(count[0]);
//    newVelocity[id] = float2(node.velocityX, node.velocityY);
    newVelocity[id] = float2(sumX, sumY);

}



