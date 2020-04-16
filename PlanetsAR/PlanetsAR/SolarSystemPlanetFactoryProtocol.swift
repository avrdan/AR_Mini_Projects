//
//  SolarSystemPlanetFactoryProtocol.swift
//  PlanetsAR
//
//  Created by Dan Avram on 22/02/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import Foundation
import ARKit

enum PlanetType : UInt32
{
    case Sun
    case Mercury
    case Venus
    case Earth
    case Mars
    case Jupiter
    case Saturn
    case Uranus
    case Neptune
    //case Pluto
    case Moon
    case COUNT
    
    static func random() -> PlanetType
    {
        let maxValue = COUNT.rawValue;
        // don't include COUNT (otherwise, maxValue + 1)
        let rand = arc4random_uniform(maxValue)
        return PlanetType(rawValue: rand)!
    }
}

protocol PlanetFactoryProtocol
{
    static var instance : Self { get }
    func createPlanet(planetType: PlanetType, parent: SCNNode) -> SCNNode?
    // TODO: also expose the other create planet function
    func rotatePlanet(planet: SCNNode, rotationDuration: TimeInterval, rotationLoop: Bool)
    func getRelativeRotationNode(planet: SCNNode, rotationDuration: TimeInterval, rotationLoop: Bool) -> SCNNode
    func setRelativeRotation(reference: SCNNode, planet: SCNNode, rotationDuration: TimeInterval, rotationLoop: Bool)
}
