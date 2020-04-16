//
//  PlanetFactory.swift
//  PlanetsAR
//
//  Created by Dan Avram on 22/02/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import Foundation
import ARKit

private protocol PlanetOperationsProtocol {
    //func setColors(node : SCNNode, colorDiffuse : UIColor, colorSpecular : UIColor)
    
    // for geometry
    func createSun(parent : SCNNode)     -> SCNNode
    func createMercury(parent : SCNNode) -> SCNNode
    func createVenus(parent : SCNNode)   -> SCNNode
    func createEarth(parent : SCNNode)   -> SCNNode
    func createMars(parent : SCNNode)    -> SCNNode
    func createJupiter(parent : SCNNode) -> SCNNode
    func createSaturn(parent : SCNNode)  -> SCNNode
    func createUranus(parent : SCNNode)  -> SCNNode
    func createNeptune(parent : SCNNode) -> SCNNode
    //func createPluto(node: SCNNode)
    func createMoon(parent : SCNNode) -> SCNNode
    
    func planet(parent: SCNNode, geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?,
                emission: UIImage?, normal: UIImage?, position: SCNVector3,
                rotationDuration: TimeInterval, rotationLoop: Bool) -> SCNNode
}


final class PlanetFactory : PlanetFactoryProtocol, PlanetOperationsProtocol
{    
    static let instance : PlanetFactory = PlanetFactory()
    
    func createPlanet(planetType: PlanetType, parent: SCNNode) -> SCNNode?
    {
        switch planetType {
            case .Sun:
                return createSun(parent : parent)
            case .Mercury:
                return createMercury(parent : parent)
            case .Venus:
                return createVenus(parent : parent)
            case .Earth:
                return createEarth(parent : parent)
            case .Mars:
                return createMars(parent : parent)
            case .Jupiter:
                return createJupiter(parent : parent)
            case .Saturn:
                return createSaturn(parent : parent)
            case .Uranus:
                return createUranus(parent : parent)
            case .Neptune:
                return createNeptune(parent : parent)
            case .Moon:
                return createMoon(parent: parent)
        default:
            break
        }
        return nil
    }
    
    func rotatePlanet(planet: SCNNode, rotationDuration: TimeInterval = 0, rotationLoop: Bool = true)
    {
        if (rotationDuration > 0)
        {
            // add rotation
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: rotationDuration)
            if (rotationLoop)
            {
                let forever = SCNAction.repeatForever(action)
                planet.runAction(forever)
            }
            else
            {
                planet.runAction(action)
            }
        }
    }
    
    func getRelativeRotationNode(planet: SCNNode, rotationDuration: TimeInterval, rotationLoop: Bool = true) -> SCNNode
    {
        let parentPlanet = SCNNode()
        parentPlanet.position = planet.position;
        rotatePlanet(planet: parentPlanet, rotationDuration:  rotationDuration, rotationLoop: rotationLoop)
        return parentPlanet
    }
    
    func setRelativeRotation(reference: SCNNode, planet: SCNNode, rotationDuration: TimeInterval, rotationLoop: Bool)
    {
        guard let ancestor = reference.parent else
        {
            //show("Relative rotation cannot be applied, parent is nil!")
            return
            
        }
        
        let parent : SCNNode = getRelativeRotationNode(planet : planet,
                                         rotationDuration: rotationDuration, rotationLoop: rotationLoop)
        ancestor.addChildNode(parent)
    }
    
    fileprivate func planet(parent: SCNNode, geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?,
                emission: UIImage?, normal: UIImage?, position: SCNVector3,
                rotationDuration: TimeInterval = 0, rotationLoop: Bool = true) -> SCNNode
    {
        let planet = SCNNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents  = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents   = normal
        planet.position = position
        parent.addChildNode(planet)
        rotatePlanet(planet: planet, rotationDuration: rotationDuration, rotationLoop: rotationLoop)
        
        return planet
    }
    
    fileprivate func createSun(parent: SCNNode) -> SCNNode
    {
        let node = planet(parent: parent, geometry: SCNSphere(radius: 0.35), diffuse: #imageLiteral(resourceName: "Sun - Diffuse"),
                          specular: nil, emission: nil, normal: nil, position: SCNVector3(0, 0, -1),
                          rotationDuration:  8)
        return node
    }
    
    fileprivate func createMercury(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createVenus(parent: SCNNode) -> SCNNode
    {
        let node = planet(parent: parent, geometry: SCNSphere(radius: 0.1), diffuse: #imageLiteral(resourceName: "Venus - Surface"), specular: nil,
                          emission: #imageLiteral(resourceName: "Venus - Atmosphere"), normal: nil, position: SCNVector3(0.7, 0, 0), rotationDuration: 8)
        return node
    }
    
    fileprivate func createEarth(parent: SCNNode) -> SCNNode
    {
        let node = planet(parent: parent, geometry: SCNSphere(radius: 0.2), diffuse: #imageLiteral(resourceName: "Earth - Day"), specular: #imageLiteral(resourceName: "Earth - Specular"),
                          emission: #imageLiteral(resourceName: "Earth - Emission"), normal: #imageLiteral(resourceName: "Earth - Normal"), position: SCNVector3(1.2, 0, 0), rotationDuration: 8)
        return node
    }
    
    fileprivate func createMars(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createJupiter(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createSaturn(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createUranus(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createNeptune(parent: SCNNode) -> SCNNode
    {
        let node = SCNNode(geometry: SCNSphere(radius: 0.2))
        return node
    }
    
    fileprivate func createMoon(parent: SCNNode) -> SCNNode
    {
        let node = planet(parent: parent, geometry: SCNSphere(radius: 0.05), diffuse: #imageLiteral(resourceName: "Moon - Diffuse"),
                          specular: nil, emission: nil, normal: nil, position: SCNVector3(0, 0, -0.3))
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 4)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
        
        return node
    }
}
