//
//  ARNodeManager.swift
//  ARDefence
//
//  Created by Ben Nowak on 11/19/17.
//  Copyright © 2017 Ben Nowak. All rights reserved.
//

import Foundation
import ARKit

protocol ARNodeManagerDelegate {
    
    func shouldShowStartButton(_ show: Bool)
    func shouldUpdateScore(_ score: Int)
    func shouldUpdateDamage(_ damage: Int)
    func shouldDrawNode(_ node: SCNNode)
    func removeAllChildNodes()
    
    func returnPosition() -> float4x4
    
}

class ARNodeManager {
    
    var delegate: ARNodeManagerDelegate?
    
    var maxNodes = 5
    var maxHits = 3
    
    var destroyedNodes = 0
    var hitsTaken = 0
    
    var gameOver = false
    
    func initializeGame() {
        
        guard let del = delegate else {
            return
        }
        
        destroyedNodes = 0
        hitsTaken = 0
        gameOver = false
        
        createInitialNodes()
        del.shouldShowStartButton(false)
        del.shouldUpdateScore(destroyedNodes)
        del.shouldUpdateDamage(maxHits - hitsTaken)
        
    }
    
    func endGame() {
        
        guard let del = delegate else {
            return
        }
        
        gameOver = true
        del.removeAllChildNodes()
        del.shouldShowStartButton(true)
        
    }
    
    func processTapInSceneView(sceneView: ARSCNView, recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        
        guard let node = hitTestResults.first?.node,
            let del = delegate else {
            return
        }
        
        //if we made it this far, we tapped an enemyNode
        destroyedNodes += 1
        del.shouldUpdateScore(destroyedNodes)
        
        node.removeFromParentNode()
        
        //create new enemy to replace it
        createEnemyNode()

    }
    
    func createEnemyNode() {
        
        guard let del = delegate else {
            return
        }
        
        let enemyBox = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let enemyNode = SCNNode()
        enemyNode.geometry = enemyBox
        enemyNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        enemyNode.position = getRandomPositionFromCamera()
        
        let destination = SCNVector3(del.returnPosition().translation)
        self.moveNodeToPosition(node: enemyNode, position: destination)
        
        del.shouldDrawNode(enemyNode)
        
    }
    
    func createInitialNodes() {
        
        for index in 1...maxNodes {
            
            let delay = 1.0 + Double(index)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
                self.createEnemyNode()
            })
            
        }
        
    }
    
    func getRandomPositionFromCamera() -> SCNVector3 {
        
        let x = Float.random(min: -2.0, max: 2.0)
        let y = Float.random(min: 0, max: 2.0)
        let z = Float.random(min: -5.0, max: 5.0)
        
        return SCNVector3(x: x, y: y, z: z)
        
    }
    
    func moveNodeToPosition(node: SCNNode, position: SCNVector3) {
        
        let moveTowardsOriginAction = SCNAction.move(to: position, duration: 8.0)
        node.runAction(moveTowardsOriginAction, completionHandler: {
            self.handlePotentialHit(node: node)
        })
        
        let rotationAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: 1.0)
        let infiniteRotationAction = SCNAction.repeatForever(rotationAction)
        node.runAction(infiniteRotationAction)
    }
    
    func handlePotentialHit(node: SCNNode) {
        
        //if this node is still in the parent tree, it hit us
        if let _ = node.parent, let del = delegate {
            hitsTaken += 1
            del.shouldUpdateDamage(maxHits - hitsTaken)
        }
        
        node.removeFromParentNode()
        
        if (maxHits - hitsTaken > 0) {
            createEnemyNode()
        }
        else {
            endGame()
        }
        
    }
    
}

extension Float {
    
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
