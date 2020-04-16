//
//  ViewController.swift
//  AR Drawing
//
//  Created by Dan Avram on 21/02/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var draw: UIButton!
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval)
    {
        guard let pointOfView = sceneView.pointOfView else { return }
        let currentCameraPos = getCurrCameraPos(pointOfView: pointOfView)
    
        DispatchQueue.main.async
        {
            self.updateDraw(cameraPos: currentCameraPos)
        }
    }
    
    func getCurrCameraPos(pointOfView: SCNNode, debug: Bool = false) -> SCNVector3
    {
        let transform = pointOfView.transform
        // orientation is in the third color of the transform matrix
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        // location is in the fourth column of the transform matrix
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        if debug
        {
            print(orientation.x, orientation.y, orientation.z)
        }
        
        return orientation + location
    }
    
    func updateDraw(cameraPos: SCNVector3)
    {
        if draw.isHighlighted
        {
            drawSphere(cameraPos: cameraPos)
            //updatePointer(cameraPos: cameraPos)
        }
        else
        {
            updatePointer(cameraPos: cameraPos)
        }
    }
    
    func drawSphere(cameraPos: SCNVector3)
    {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
        sphereNode.position = cameraPos
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
    
    func updatePointer(cameraPos: SCNVector3)
    {
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
            if (node.name == "pointer")
            {
                node.removeFromParentNode()
            }
        })
        
        let size : CGFloat = 0.01
        let pointer = SCNNode(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: size / 2))
        pointer.name = "pointer"
        pointer.position = cameraPos
        self.sceneView.scene.rootNode.addChildNode(pointer)
        pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.white
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3
{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
