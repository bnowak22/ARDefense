//
//  ARNodeManager.swift
//  ARDefence
//
//  Created by Ben Nowak on 11/19/17.
//  Copyright © 2017 Ben Nowak. All rights reserved.
//

import Foundation
import ARKit

enum ARNodeType: String {
    case StartButton = "startButton"
    case EnemyProjectile = "enemyProjectile"
}

class ARNodeManager {
    
    var maxNodes = 5
    var destroyedNodes = 0
    var hitsTaken = 0
    
    var sceneView: ARSCNView?
    
    convenience init(withSceneView sceneView: ARSCNView) {
        self.init()
        
        self.sceneView = sceneView;
    }
    
    func createEnemyNode() {
        
        guard let scnView = self.sceneView else {
            return
        }
        
        let enemyBox = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let enemyNode = SCNNode()
        enemyNode.geometry = enemyBox
        enemyNode.position = getRandomPositionFromCamera()
        enemyNode.name = ARNodeType.EnemyProjectile.rawValue
        
        if let cameraPosition = scnView.session.currentFrame?.camera.transform.translation {
            let destination = SCNVector3(cameraPosition)
            self.moveNodeToPosition(node: enemyNode, position: destination)
        }
        
        
        scnView.scene.rootNode.addChildNode(enemyNode)
        
    }
    
    func createInitialNodes() {
        
        self.createEnemyNode()
        self.createEnemyNode()
        self.createEnemyNode()
        self.createEnemyNode()
        self.createEnemyNode()
        
    }
    
    func getRandomPositionFromCamera() -> SCNVector3 {
        
        let x = Float.random(min: -2.0, max: 2.0)
        let y = Float.random(min: 0, max: 2.0)
        let z = Float.random(min: -5.0, max: 5.0)
        
        return SCNVector3(x: x, y: y, z: z)
        
    }
    
    func moveNodeToPosition(node: SCNNode, position: SCNVector3) {
        
        let moveTowardsOriginAction = SCNAction.move(to: position, duration: 10.0)
        node.runAction(moveTowardsOriginAction, completionHandler: {
            
            //if this node is still in the parent tree, it hit us
            if let _ = node.parent {
                self.hitsTaken += 1
            }
            
            node.removeFromParentNode()
            
        })
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
