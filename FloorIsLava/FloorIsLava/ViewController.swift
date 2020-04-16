//
//  ViewController.swift
//  FloorIsLava
//
//  Created by Dan Avram on 02/03/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                       ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.configuration.planeDetection = .horizontal
        self.sceneView.delegate = self
        
        //let lavaNode = createLava()
        //self.sceneView.scene.rootNode.addChildNode(lavaNode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLava(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        lavaNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Lava")
        lavaNode.position = SCNVector3(planeAnchor.center.x,
                                       planeAnchor.center.y, planeAnchor.center.z)
        lavaNode.eulerAngles = SCNVector3(CGFloat(90.degreesToRadians), 0 , 0)
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true // texture on both sides
        return lavaNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("New flat surface detected. New ARPlaneAnchor added")
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("updating plane anchor...")
        node.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("removing anchor...")
        node.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
}

extension Int {
    var degreesToRadians : Double { return Double(self) * .pi/180 }
}

