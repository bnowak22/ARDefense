//
//  ViewController.swift
//  ARDefence
//
//  Created by Ben Nowak on 11/19/17.
//  Copyright © 2017 Ben Nowak. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController, ARNodeManagerDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let nodeManager = ARNodeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add gesture recognizer
        addTapGestureToSceneView()
        
        //show start button
        shouldShowStartButton(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        
        nodeManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Gesture recognizer
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        nodeManager.processTapInSceneView(sceneView: sceneView, recognizer: recognizer)
    }
    
    @IBAction func beginGame(_ sender: Any) {
        nodeManager.initializeGame()
    }
    
    // MARK: Animations
    func sceneViewFlashRed() {
        
        let redView = UIView(frame: self.view.frame)
        redView.backgroundColor = UIColor.red
        redView.alpha = 0.5
        
        DispatchQueue.main.async {
            self.view.addSubview(redView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            redView.removeFromSuperview()
        })
        
    }
    
    // MARK: ARNodeManagerDelegate
    
    func shouldShowStartButton(_ show: Bool) {
        startButton.isHidden = !show
    }
    
    func shouldUpdateScore(_ score: Int) {
        DispatchQueue.main.async {
            self.pointsLabel.text = "Score: " + score.description
        }
    }
    
    func shouldUpdateDamage(_ damage: Int) {
        
        if (damage >= 0) {
            sceneViewFlashRed()
        }
        
        DispatchQueue.main.async {
            self.livesLabel.text = "Lives: " + damage.description
        }
    }
    
    func removeAllChildNodes() {
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }

    func returnPosition() -> float4x4 {
        return (sceneView.session.currentFrame?.camera.transform)!
    }
    
    func shouldDrawNode(_ node: SCNNode) {
        sceneView.scene.rootNode.addChildNode(node)
    }
    
}

