import SpriteKit

class DragToSelectCard: Card {
    lazy var myPlanets: [PlanetNode] = {
        var planets = [PlanetNode]()
        self.enumerateChildNodes(withName: "tutorialPlanet_planet*", using: { (node, _) in
            planets.append(node as! PlanetNode)
        })
        return planets
    }()
    
    lazy var darkPlanet: PlanetNode = {
        return self.childNode(withName: "tutorialPlanet_darkPlanet") as! PlanetNode
    }()
    
    var croppedPath: SKCropNode!
    
    lazy var path: SKSpriteNode = {
        return self.childNode(withName: "instruction/Path") as! SKSpriteNode
    }()
    
    override func switchedOn() {
        for planet in self.myPlanets {
            planet.currentOwner = .player
            planet.population = 10
        }
        self.darkPlanet.currentOwner = .enemy
        self.darkPlanet.population = 12
        self.hasTutorial = true
        self.planets.append(contentsOf: self.myPlanets)
        self.planets.append(self.darkPlanet)
        
        //Cropped Path
        self.croppedPath = SKCropNode()
        self.instruction!.addChild(self.croppedPath)
        let mask = self.childNode(withName: "instruction/mask")
        self.croppedPath.maskNode = mask
        self.path.move(toParent: self.croppedPath)
        self.path.isPaused = false
        
        self.run(SKAction.wait(forDuration: 0.7)) {
            self.instruction?.isPaused = false
        }
    }
    
    override func mouseDownFromScene(nodes: [SKNode]) {
        super.mouseDownFromScene(nodes: nodes)
        for planet in self.myPlanets {
            if nodes.contains(planet) {
                self.instruction?.removeFromParent()
                // self.croppedPath.removeFromParent()
                break
            }
        }
    }
    
    override func isTutorialCompleted() -> Bool {
        return self.darkPlanet.currentOwner == .player
    }
}
