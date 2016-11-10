//
//  Shaders.metal
//  GPUCalc1
//
//  Created by Yukinaga2 on 2016/10/03.
//  Copyright © 2016年 Yukinaga. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float alpha = 0.025;
constant float beta = 0.2;
constant float gamma = 0.005;

constant float spaceRatio = 0.12;

struct Node
{
    float positionX;
    float positionY;
    float velocityX;
    float velocityY;
    float angle;
};

static float getDistace(float x1, float y1, float x2, float y2)
{
    float dx = x1-x2;
    float dy = y1-y2;
    return sqrt(dx*dx + dy*dy);
}

//From -pi to pi
static float getRangedAngle(float angle)
{
    if (angle > M_PI_F){
        angle -= 2 * M_PI_F;
    }else if (angle < -M_PI_F){
        angle += 2 * M_PI_F;
    }
    return angle;
}

kernel void move(const device Node *inNode [[ buffer(0) ]],
                 const device uint &nodeCount [[ buffer(1) ]],
                 const device float &interval [[ buffer(2) ]],
                 const device float &width [[ buffer(3) ]],
                 const device float &height [[ buffer(4) ]],
                 device Node *outNode [[ buffer(5) ]],
                 uint id [[ thread_position_in_grid ]])
{
    Node currentNode = inNode[id];
    
    float a = width * spaceRatio;
    float b = 6.25 / a / a;
    float dAngle = 0;
    
    float velocityX = currentNode.velocityX;
    float velocityY = currentNode.velocityY;
    float velocity = sqrt(velocityX*velocityX + velocityY*velocityY);
    
    float outerSpace = width * 0.1;
    
    for (uint i=0; i<nodeCount; i++){
        if (i == id){
            continue;
        };
        
        Node node = inNode[i];
        
        float distance = getDistace(node.positionX, node.positionY, currentNode.positionX, currentNode.positionY);
        
        float nearAngle = getRangedAngle(atan2(node.positionX-currentNode.positionX, node.positionY-currentNode.positionY) - currentNode.angle);
        float farAngle = getRangedAngle(atan2(currentNode.positionX-node.positionX, currentNode.positionY-node.positionY) - currentNode.angle);
        float attraction = exp(-b * (distance - a)*(distance - a));
        float repulsion = exp(-b * distance * distance);
        dAngle += alpha * (nearAngle*attraction + farAngle*repulsion)*interval;
        
        float parallelAngleDif = getRangedAngle(node.angle - currentNode.angle);
        dAngle += beta * parallelAngleDif * exp(-b * distance * distance) * interval;
        
        float nodeVelocity = sqrt(node.velocityX*node.velocityX + node.velocityY*node.velocityY);
        velocity += gamma * (nodeVelocity - velocity) * exp(-b * distance * distance);;
    }
    
    float newAngle = getRangedAngle(currentNode.angle + dAngle);
    velocityX = velocity * sin(newAngle);
    velocityY = velocity * cos(newAngle);
    
    float newPositionX = currentNode.positionX + velocityX;
    if (newPositionX > (width + outerSpace)) {
        newPositionX -= (width + outerSpace*2);
    }
    if (newPositionX < -outerSpace) {
        newPositionX += width + outerSpace*2;
    }
    
    float newPositionY = currentNode.positionY + velocityY;
    if (newPositionY > height + outerSpace) {
        newPositionY -= height + outerSpace*2;
    }
    if (newPositionY < -outerSpace) {
        newPositionY += height + outerSpace*2;
    }
    
    outNode[id].positionX = newPositionX;
    outNode[id].positionY = newPositionY;
    outNode[id].velocityX = velocityX;
    outNode[id].velocityY = velocityY;
    outNode[id].angle = newAngle;
}
