//
//  ViewController.swift
//  Vehicle
//
//  Created by Dan Avram on 02/03/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func addCar(_ sender: Any) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentCamPos = orientation + location
        
        let scene = SCNScene(named: "Vehicle.scn")
        let carNode = (scene?.rootNode.childNode(withName: "Frame", recursively: false))!
        let wheelFrontLeft = carNode.childNode(withName: "ParentWheelFL", recursively: false)!
        let wheelFrontRight = carNode.childNode(withName: "ParentWheelFR", recursively: false)!
        let wheelRearLeft = carNode.childNode(withName: "ParentWheelRL", recursively: false)!
        let wheelRearRight = carNode.childNode(withName: "ParentWheelRR", recursively: false)!
        
        let v_wheelFrontLeft = SCNPhysicsVehicleWheel(node: wheelFrontLeft)
        let v_wheelFrontRight = SCNPhysicsVehicleWheel(node: wheelFrontRight)
        let v_wheelRearLeft = SCNPhysicsVehicleWheel(node: wheelRearLeft)
        let v_wheelRearRight = SCNPhysicsVehicleWheel(node: wheelRearRight)
        
        carNode.position = currentCamPos
        
        let body = SCNPhysicsBody(type: .dynamic,
                                  shape: SCNPhysicsShape(node: carNode,
                                  options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        body.mass = 13
        carNode.physicsBody = body
        
        self.vehicle = SCNPhysicsVehicle(chassisBody: carNode.physicsBody!,
                                         wheels: [v_wheelFrontLeft, v_wheelFrontRight, v_wheelRearLeft, v_wheelRearRight])
        self.sceneView.scene.physicsWorld.addBehavior(self.vehicle)
        self.sceneView.scene.rootNode.addChildNode(carNode)
    }
    
    let configuration = ARWorldTrackingConfiguration()
    let motionManager = CMMotionManager()
    var vehicle = SCNPhysicsVehicle()
    var orientation:CGFloat = 0
    var touched: Int = 0
    var accelerationValues = [UIAccelerationValue(0), UIAccelerationValue(0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                       ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.configuration.planeDetection = .horizontal
        self.sceneView.delegate = self
        self.setupAccelerometer()
        self.sceneView.showsStatistics = true
        
        //let concreteNode = createConcrete()
        //self.sceneView.scene.rootNode.addChildNode(concreteNode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {return}
        self.touched += touches.count
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = 0
    }
    
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Concrete")
        concreteNode.position = SCNVector3(planeAnchor.center.x,
                                       planeAnchor.center.y, planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(CGFloat(90.degreesToRadians), 0 , 0)
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true // texture on both sides
        
        // enable static collision
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        
        return concreteNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("New flat surface detected. New ARPlaneAnchor added")
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("updating plane anchor...")
        node.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print ("removing anchor...")
        node.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    func setupAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            
            motionManager.accelerometerUpdateInterval = 1/60
            motionManager.startAccelerometerUpdates(to: .main, withHandler:
                { (accelerometerData, error) in
                    if let error = error {
                        print (error.localizedDescription)
                        return
                    }
                    
                    //print ("Accelerometer is detecting acceleration")
                    self.accelerometerDidChange(acceleration: accelerometerData!.acceleration)
            })
        } else {
            print("Accelerometer not available!")
        }
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
        // filter y acceleration
        self.accelerationValues[1] = filtered(previousAcceleration: self.accelerationValues[1], UpdatedAcceleration: acceleration.y)
        
        // filter x acceleration
        self.accelerationValues[0] = filtered(previousAcceleration: self.accelerationValues[0], UpdatedAcceleration: acceleration.x)
        
        if self.accelerationValues[0] > 0 {
            self.orientation = -CGFloat(self.accelerationValues[1])
        }
        else {
            self.orientation = CGFloat(self.accelerationValues[1])
        }
        //print(acceleration.x)
        //print(acceleration.y)
        //print("")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        //print("simulating physics")
        var engineForce: CGFloat = 0
        var breakingForce: CGFloat = 0
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 0)
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 1)
        
        if self.touched == 1 {
            engineForce = 50
        } else if self.touched == 2 {
            engineForce = -50
        } else if self.touched == 3 {
            breakingForce = 100;
        } else {
            engineForce = 0
        }
        
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 2)
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 3)
        self.vehicle.applyBrakingForce(breakingForce, forWheelAt: 2)
        self.vehicle.applyBrakingForce(breakingForce, forWheelAt: 3)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func filtered(previousAcceleration: Double, UpdatedAcceleration: Double) -> Double {
    let kfilteringFactor = 0.5
    return UpdatedAcceleration * kfilteringFactor + previousAcceleration * (1 - kfilteringFactor)
}

extension Int {
    var degreesToRadians : Double { return Double(self) * .pi/180 }
}

