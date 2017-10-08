//
//  StoreSceneViewController.swift
//  Surprise
//
//  Created by zhengperry on 2017/9/24.
//  Copyright © 2017年 mmoaay. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SVProgressHUD

import CoreML
import Vision

extension StoreSceneViewController: SwitchViewDelegate {
    func switched(status: OperationStatus) {
        self.status = status
        switch status {
        case .locating:
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            // Run the view's session
            sceneView.session.run(configuration)
            break
        case .done:
            if let last = self.last {
                let box = SCNBox(width: Constant.ROUTE_DOT_RADIUS*5, height: Constant.ROUTE_DOT_RADIUS*5, length: Constant.ROUTE_DOT_RADIUS*5, chamferRadius: 0)
                let node = SCNNode(geometry: box)
                node.position = last
                node.geometry?.firstMaterial?.diffuse.contents = UIColor(hexColor: "CD4F39")
                sceneView.scene.rootNode.addChildNode(node)
                
                self.last = nil
            }
            
            self.nameView.isHidden = false
            self.nameTextField.becomeFirstResponder()
        case .save:
            
            let route = Route(name: nameTextField.text!, time: NSDate(), scene: self.sceneView.scene)
            if true == RouteCacheService.shared.addRoute(route: route) {
                self.navigationController?.popViewController(animated: true)
                
                self.nameView.isHidden = true
                self.nameTextField.resignFirstResponder()
            } else {
                print("Save failed")
            }
            
            
            break
        default:
            break
        }
    }
}

class StoreSceneViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var switchView: SwitchView!
    
    var status:OperationStatus = .locating
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var last: SCNVector3? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        switchView.type = .store
        switchView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if .going == status {
            guard let pointOfView = sceneView.pointOfView else { return }
            
            let current = pointOfView.position
            if let last = self.last {
                if last.distance(vector: current) < Constant.ROUTE_DOT_INTERVAL { return }
                
                let sphere = SCNSphere(radius: Constant.ROUTE_DOT_RADIUS)
                let node = SCNNode(geometry: sphere)
                node.position = current
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                sceneView.scene.rootNode.addChildNode(node)
            } else {
                let box = SCNBox(width: Constant.ROUTE_DOT_RADIUS*5, height: Constant.ROUTE_DOT_RADIUS*5, length: Constant.ROUTE_DOT_RADIUS*5, chamferRadius: 0)
                let node = SCNNode(geometry: box)
                node.position = current
                node.geometry?.firstMaterial?.diffuse.contents = UIColor(hexColor: "43CD80")
                sceneView.scene.rootNode.addChildNode(node)
            }
            
            self.last = current
            
            glLineWidth(0)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}