//
//  ViewController.swift
//  AR-Portal
//
//  Created by Dan Avram on 10/06/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var planeDetected: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
            ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            // add room
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            ////
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXpos = transform.columns.3.x
        let planeYpos = transform.columns.3.y
        let planeZpos = transform.columns.3.z
        portalNode.position = SCNVector3(planeXpos, planeYpos, planeZpos)
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        self.addPlane(nodeName: "roof", portalNode: portalNode, imgName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imgName: "bottom")
        self.addPlane(nodeName: "backWall", portalNode: portalNode, imgName: "back", hasMask: true)
        self.addPlane(nodeName: "sideDoorA", portalNode: portalNode, imgName: "sideDoorA", hasMask: true)
        self.addPlane(nodeName: "sideDoorB", portalNode: portalNode, imgName: "sideDoorB", hasMask: true)
        self.addPlane(nodeName: "sideWallA", portalNode: portalNode, imgName: "sideA", hasMask: true)
        self.addPlane(nodeName: "sideWallB", portalNode: portalNode, imgName: "sideB", hasMask: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imgName: String, hasMask: Bool = false) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents =
            UIImage(named: "Portal.scnassets/\(imgName).png")
        child?.renderingOrder = 200 // render behind the mask, if any
        
        if hasMask == true {
            if let mask = child?.childNode(withName: "mask", recursively: false) {
                mask.geometry?.firstMaterial?.transparency = 0.000001
            }
        }
    }
}

