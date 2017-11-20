//
//  ViewController.swift
//  ARDefence
//
//  Created by Ben Nowak on 11/19/17.
//  Copyright © 2017 Ben Nowak. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var nodeManager = ARNodeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add gesture recognizer
        addTapGestureToSceneView()
        
        //create start button
        createStartButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        
        nodeManager = ARNodeManager(withSceneView: sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AR helper methods
    
    func createStartButton() {
        
        let startButtonBox = SCNBox(width: 0.1, height: 0.1, length: 0.3, chamferRadius: 0)
        
        let startButtonNode = SCNNode()
        startButtonNode.geometry = startButtonBox
        startButtonNode.position = SCNVector3(0, 0, -0.2)
        startButtonNode.name = ARNodeType.StartButton.rawValue
        
        sceneView.scene.rootNode.addChildNode(startButtonNode)
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        
        guard let node = hitTestResults.first?.node else {
            return
        }
        
        switch node.name {
            case ARNodeType.StartButton.rawValue?:
                
                //draw all new nodes
                node.removeFromParentNode()
                nodeManager.createInitialNodes()
                break
            
            case ARNodeType.EnemyProjectile.rawValue?:
                
                //update score
                nodeManager.destroyedNodes += 1
                
                //remove tapped node
                node.removeFromParentNode()
                
                //add new node
                nodeManager.createEnemyNode()
                
                break
            
            default:
                break
        }
        
    }
    
}

