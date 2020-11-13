import SpriteKit

class ClickToSelectCard: Card {
    
    lazy var earth: PlanetNode = {
        return self.childNode(withName: "tutorialPlanet_Earth") as! PlanetNode
    }()
    
    lazy var brownPlanet: PlanetNode = {
        return self.childNode(withName: "tutorialPlanet_brownPlanet") as! PlanetNode
    }()
    
    override func switchedOn() {
        self.earth.currentOwner = .player
        self.earth.population = 30
        self.brownPlanet.currentOwner = .enemy
        self.brownPlanet.population = 10
        self.hasTutorial = true
        self.planets = [earth, brownPlanet]
        self.run(SKAction.wait(forDuration: 0.7)) { 
            self.instruction?.isPaused = false
        }
    }
    
    override func mouseMovedFromScene(nodes: [SKNode]) {
        super.mouseMovedFromScene(nodes: nodes)
        if nodes.contains(self.earth) {
            self.instruction?.removeFromParent()
        }
    }
    
    override func isTutorialCompleted() -> Bool {
        return self.brownPlanet.currentOwner == .player
    }
}
