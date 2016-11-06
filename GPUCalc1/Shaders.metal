//
//  Shaders.metal
//  GPUCalc1
//
//  Created by Yukinaga2 on 2016/10/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float spaceRatio = 0.08;
constant float acceration = 0.02;

struct Node
{
    float positionX;
    float positionY;
    float velocityX;
    float velocityY;
    float angle;
};

static float getDistace(float x1, float y1, float x2, float y2){
    float dx = x1-x2;
    float dy = y1-y2;
    return sqrt(dx*dx + dy*dy);
}

//From -pi to pi
static float getRangedAngle(float angle){
    if (angle > M_PI_F){
        angle -= 2 * M_PI_F;
    }else if (angle < -M_PI_F){
        angle += 2 * M_PI_F;
    }
    return angle;
}

kernel void move(const device Node *inNode [[ buffer(0) ]],
                 const device uint &nodeCount [[ buffer(1) ]],
                 const device uint &interval [[ buffer(2) ]],
                 const device uint &width [[ buffer(3) ]],
                 const device uint &height [[ buffer(4) ]],
                 device Node *outNode [[ buffer(5) ]],
                 uint id [[ thread_position_in_grid ]])
{
    Node currentNode = inNode[id];
    float alpha = width * spaceRatio;
    float beta = 6.25 / alpha / alpha;
    float dAngle = 0;
    for (uint i=0; i<nodeCount; i++){
        
        if (i == id){
            continue;
        };
        
        Node node = inNode[i];
        
        float distance = getDistace(node.positionX, node.positionY, currentNode.positionX, currentNode.positionY);
        float nearAngle = atan2(node.positionX-currentNode.positionX, node.positionY-currentNode.positionY);
        float farAngle = atan2(currentNode.positionX-node.positionX, currentNode.positionY-node.positionY);
        float parallelAngleDif = getRangedAngle(node.angle-currentNode.angle);
        
        float attraction = exp(-beta * (distance - alpha)*(distance - alpha));
        float repulsion = -exp(-beta * distance * distance);

        dAngle += acceration*(nearAngle*attraction + farAngle*repulsion);
    }
    
    
    
    //for (uint i=0; i<10000; i++){
        //        if (i < 5000){
        ////            sumX += ary[i];
        ////            sumY += ary[i];
        //
        //sumX += position[i].x;
        //sumY += position[i].y;
        //        }else{
        //            sumX += position[id].y;
        //            sumY += position[id].x;
        //
        //        }
        //        sumX += node.positionX;
        //        sumY += node.positionY;
    //}
    //    float tt = float(count[0]);
    //    newVelocity[id] = float2(node.velocityX, node.velocityY);
    //newVelocity[id] = float2(sumX, sumY);
//    outNode[id] = inNode[id];
    outNode[id].positionX = inNode[id].positionX;
    outNode[id].positionY = inNode[id].positionY;
    outNode[id].velocityX = inNode[id].velocityX;
    outNode[id].velocityY = inNode[id].velocityY;
    outNode[id].angle = inNode[id].angle + dAngle;

}




