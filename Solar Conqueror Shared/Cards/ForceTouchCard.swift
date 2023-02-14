import SpriteKit

class ForceTouchCard: Card {
    
    lazy var firePlanet: PlanetNode = {
        return self.childNode(withName: "tutorialPlanet_firePlanet") as! PlanetNode
    }()
    
    lazy var forceEmitter: SKEmitterNode = {
        return self.childNode(withName: "instruction/ForceEmitter") as! SKEmitterNode
    }()
    
    var tutorialCompleted = false
    
    override func switchedOn() {
        self.firePlanet.currentOwner = .enemy
        self.firePlanet.population = 30
        self.hasTutorial = true
        self.planets.append(self.firePlanet)
        self.forceEmitter.alpha = 0.0
        self.run(SKAction.wait(forDuration: 0.4)) {
            self.instruction?.isPaused = false
        }
        // let reset =
        // self.forceEmitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.7)]))
    }
    
    override func switchedOff() {
        (scene as? InteractableScene)?.enemyForceTouchSound.run(SKAction.stop())
    }
    
    override func mouseMovedFromScene(nodes: [SKNode]) {
        super.mouseMovedFromScene(nodes: nodes)
        if nodes.contains(self.firePlanet) {
            self.instruction?.removeFromParent()
        }
    }
    
    override func isTutorialCompleted() -> Bool {
        if self.firePlanet.isForceTouched && self.action(forKey: "delay") == nil {
            self.run(SKAction.sequence([SKAction.wait(forDuration: 5.0), SKAction.run {
                self.tutorialCompleted = true
                }, SKAction.wait(forDuration: 2.0), SKAction.run {
                    self.firePlanet.cancelForceTouch()
                }]), withKey: "delay")
        }
        return tutorialCompleted
    }
    
}
