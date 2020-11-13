import SpriteKit

class Card: SKNode {
    
    lazy var nextButton: SKNode? = {
        if let node = self.childNode(withName: "next") {
            if let textNode = node as? SKLabelNode {
                textNode.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
                textNode.colorBlendFactor = 1.0
                return textNode
            }
            return node
        } else {
            return nil
        }
    }()
    
    lazy var glassCard: SKNode = {
        return self.childNode(withName: "GlassCard")!
    }()
    
    lazy var tutor: SKNode? = {
        return self.childNode(withName: "instruction/tutor")
    }()
    
    lazy var instruction: SKNode? = {
        return self.childNode(withName: "instruction")
    }()
    
    var planets = [PlanetNode]()
    
    var hasTutorial = false
    
    var vibrantButtons: [SKNode]  {
        if self.nextButton != nil {
            return [self.nextButton!]
        } else {
            return []
        }
    }
    
    func mouseDownFromScene(nodes: [SKNode]) {
//        print(nodes)
//        print(vibrantButtons)
        for button in vibrantButtons {
            if nodes.contains(button) {
                button.setValue(0, forKey: "colorBlendFactor")
            } else {
                button.setValue(1.0, forKey: "colorBlendFactor")
            }
        }
    }
    
    func mouseUpFromScene(nodes: [SKNode]) {
        //         print(self.nextButton)
        if let nButton = self.nextButton {
            if nodes.contains(nButton) {
                let cardsScene = self.scene as! CardsScene
                cardsScene.switchCard(to: cardsScene.currentCardIndex + 1, isInstant: false)
            }
        }
    }
    
    func mouseMovedFromScene(nodes: [SKNode]) {
        for button in vibrantButtons {
            if nodes.contains(button) {
                button.setValue(0.5, forKey: "colorBlendFactor")
            } else {
                button.setValue(1.0, forKey: "colorBlendFactor")
            }
        }
    }
    
    func mouseDraggedFromScene(nodes: [SKNode]) {
        
    }
    
    
    //    func lightUp() {
    //        //        self.light.falloff = 0.5
    //    }
    //
    //    func dim() {
    //        //        self.light.falloff = 5.0
    //    }
    
    func switchedOn() {
        
    }
    
    func switchedOff() {
        
    }
    
    func isTutorialCompleted() -> Bool {
        return false
    }
    
    func giveATickAndSwitchOnToNext() {
        (self.scene as! CardsScene).switchingCard = true
        let tick = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "tick.png")))
        tick.alpha = 0.8
        tick.scale(to: CGSize.zero)
        for child in self.children {
            child.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
        }
        self.addChild(tick)
        tick.run(SKAction.sequence([SKAction.playSoundFileNamed("Success.m4a", waitForCompletion: false), SKAction.scale(to: CGSize(width: 300, height: 300), duration: 0.6), SKAction.scale(to: CGSize(width: 250, height: 250), duration: 0.1), SKAction.wait(forDuration: 0.5)])) {
            let cardsScene = self.scene as! CardsScene
            cardsScene.switchCard(to: cardsScene.currentCardIndex + 1, isInstant: false)
            cardsScene.switchingCard = false
        }
    }
    
    func delayTransitionToPlanetsScene() {
        let cardScene = self.scene as! CardsScene
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.7), SKAction.run {
            cardScene.transitionToPlanetScene()
            }]))
    }
}
