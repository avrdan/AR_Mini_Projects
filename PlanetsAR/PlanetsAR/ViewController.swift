//
//  ViewController.swift
//  PlanetsAR
//
//  Created by Dan Avram on 22/02/2018.
//  Copyright © 2018 Dan Avram. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                       ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let sun = PlanetFactory.instance.createPlanet(planetType: PlanetType.Sun,
                                                            parent: self.sceneView.scene.rootNode) else { return }
        let parentEarth = PlanetFactory.instance.getRelativeRotationNode(planet: sun, rotationDuration: 14)
        let parentVenus = PlanetFactory.instance.getRelativeRotationNode(planet: sun, rotationDuration: 10)
        self.sceneView.scene.rootNode.addChildNode(parentEarth)
        self.sceneView.scene.rootNode.addChildNode(parentVenus)
        guard let earth = PlanetFactory.instance.createPlanet(planetType: PlanetType.Earth, parent: parentEarth) else { return }
        let _ = PlanetFactory.instance.createPlanet(planetType: PlanetType.Venus, parent: parentVenus)
        
        let parentMoon = PlanetFactory.instance.getRelativeRotationNode(planet: earth, rotationDuration: 5)
        parentEarth.addChildNode(parentMoon)
        let _ = PlanetFactory.instance.createPlanet(planetType: PlanetType.Moon, parent: parentMoon)
    }
}

