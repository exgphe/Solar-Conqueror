import SpriteKit

public class CardsScene: InteractableScene {
    lazy var cards: [Card] =  {
        return [
            self.childNode(withName: "StartCard") as! StartCard,
            self.childNode(withName: "AdjustScreenSizeCard") as! Card,
            self.childNode(withName: "ClickToSelectCard") as! ClickToSelectCard,
            self.childNode(withName: "DragToSelectCard") as! DragToSelectCard,
            self.childNode(withName: "ForceTouchCard") as! ForceTouchCard,
            self.childNode(withName: "ReadyCard") as! ReadyCard,
            self.childNode(withName: "PlanetsCard") as! PlanetsCard,
            self.childNode(withName: "FinalResultCard") as! FinalResultCard
        ]
    }()
    
    var currentCardIndex = 0
    
    func switchCard(to cardIndex: Int, isInstant: Bool) {
        let oldValue = self.currentCardIndex
        if oldValue != cardIndex {
            let difference = cardIndex - oldValue
            let duration = isInstant ? 0.0 : 0.7
            let move = SKAction.moveBy(x: CGFloat(difference * 800), y: 0, duration: duration)
            move.timingMode = .easeOut
            //                let round = SKAction.rotate(byAngle: CGFloat.pi / 4, duration: 0.25)
            //                round.timingMode = .easeInEaseOut
            self.camera!.run(move)
            self.background.run(move)
            self.light1.run(move)
            self.light2.run(move)
            self.cards[oldValue].switchedOff()
            self.cards[cardIndex].switchedOn()
            //                self.cards[oldValue].run(SKAction.sequence([round, round.reversed()]))
            //                for (index, card) in cards.enumerated() {
            //                    if index == currentCard {
            //                        print("card\(card)")
            //                        card.lightUp()
            //                    } else {
            //                        card.dim()
            //                    }
            //                }
            self.currentCardIndex = cardIndex
        }
    }
    
    var background: SKReferenceNode {
        return self.childNode(withName: "background") as! SKReferenceNode
    }
    
    var light1: SKLightNode {
        return self.childNode(withName: "light1") as! SKLightNode
    }
    var light2: SKLightNode {
        return self.childNode(withName: "light2") as! SKLightNode
    }
    
    var switchingCard = false
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        //        for card in cards {
        //            let glassCard = card.childNode(withName: "GlassCard")!
        //            for child in glassCard.children {
        //                if let light = child.childNode(withName: "light1") {
        //                    light.name = "\(card.name!)light"
        //                }
        //            }
        //        }
        //        self.cards[0].lightUp()
        (self.view as! GameView).resetPlanetsScene()
        self.enumerateChildNodes(withName: "//tutorialPlanet*") { (node, _) in
            //            print(node)
            self.planets.append(node as! PlanetNode)
        }
//        print(self.planets)
        let planetsCard = self.cards[planetCardIndex] as! PlanetsCard
        planetsCard.fakePlanetsScene.isPaused = true
        self.player.specialWeaponsLeft = 100
        for card in self.cards {
            if let instruction = card.instruction {
                instruction.isPaused = true
            }
        }
        self.cards[self.currentCardIndex].switchedOn()
    }
    
    #if os(macOS)
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let location = event.location(in: self)
        for card in self.cards {
            card.mouseUpFromScene(nodes: self.nodes(at: location))
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let location = event.location(in: self)
        for card in self.cards {
            card.mouseDownFromScene(nodes: self.nodes(at: location))
        }
        let light = SKLightNode()
        light.falloff = 5.0
        light.position = location
        self.addChild(light)
        let blink = SKAction.customAction(withDuration: 0.4) { (node: SKNode, time: CGFloat) in
            // (0, 5) (0.1, 1.5)
            (node as! SKLightNode).falloff = 50 * time * time - 20 * time + 5
        }
        
        light.run(SKAction.sequence([blink, SKAction.removeFromParent()]))
    }
    
    override public func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let location = event.location(in: self)
        for card in self.cards {
            card.mouseMovedFromScene(nodes: self.nodes(at: location))
        }
    }
    
    override public func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let location = event.location(in: self)
        for card in self.cards {
            card.mouseDraggedFromScene(nodes: self.nodes(at: location))
        }
    }
    #endif
    
    override public func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let card = self.cards[self.currentCardIndex]
        if !self.switchingCard {
            if card.hasTutorial {
                if card.isTutorialCompleted() {
                    card.giveATickAndSwitchOnToNext()
                }
            }
        }
        
    }
    
    override func planetAtThisLocation(point:CGPoint) -> PlanetNode? {
        let nodes = self.nodes(at: point)
        //        print("nodes\(nodes)")
        for n in nodes {
            //            print(n as! PlanetNode)
            if let p = n as? PlanetNode {
                let realSize = p.size
                let position = CGPoint(x: p.position.x + p.parent!.position.x, y: p.position.y + p.parent!.position.y)
                if abs(position.x - point.x) <= realSize.width / 2 && abs(position.y - point.y) <= realSize.height / 2 {
                    return p
                }
            }
        }
        return nil
    }
    
    func transitionToPlanetScene() {
        let planetsCard = self.cards[6] as! PlanetsCard
//        print(self.size)
//        print(planetsCard.frame.size)
        //        fakePlanetsScene.isPaused = true
        let background = self.childNode(withName: "background")!
        let scale = 1.0 / planetsCard.fakePlanetsScene.xScale
        //        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        //        let glassCard = planetsCard.glassCard
        //        glassCard.run(fadeOut)
        //        background.run(fadeOut)
        let initialFallOff = self.light1.falloff
        let dimOut = SKAction.customAction(withDuration: 0.5) { (node: SKNode, time: CGFloat) in
            // (0, y) (0,5, 3)
            let light = node as! SKLightNode
            light.falloff = (3.0 - initialFallOff) * time * 2.0 + initialFallOff
//            print(light.falloff)
        }
        self.light1.run(dimOut)
        self.light2.run(dimOut)
        let scaleUpAction = SKAction.scale(to: scale, duration: 0.5)
        scaleUpAction.timingMode = .easeOut
        self.run(SKAction.playSoundFileNamed("swoosh.wav", waitForCompletion: false))
        self.music.setVolume(0.0, fadeDuration: 0.5)
        planetsCard.run(scaleUpAction) {
            self.music.stop()
            (self.view as! GameView).goToPlanetsScene(background: background)
        }
    }
    
    func showResult(screenShotTexture: SKTexture, result: resultType ) {
        let planetsCard = self.cards[6] as! PlanetsCard
        let finalResultCard = self.cards[7] as! FinalResultCard
        planetsCard.screenShot.texture = screenShotTexture
        planetsCard.screenShot.isHidden = false
        self.switchCard(to: 6, isInstant: true)
        let scale = 1.0 / planetsCard.fakePlanetsScene.xScale
        planetsCard.fakePlanetsScene.isHidden = true
        planetsCard.setScale(scale)
        switch result {
        case .victory:
            let duplicatedScreenShot = planetsCard.screenShot.copy() as! SKSpriteNode
            let filter = CIFilter(name: "CIColorPosterize", parameters: ["inputLevels": 2.0])
            let effect = SKEffectNode()
            effect.filter = filter
            effect.alpha = 0.0
            planetsCard.addChild(duplicatedScreenShot)
            planetsCard.addChild(effect)
            planetsCard.screenShot.move(toParent: effect)
            effect.run(SKAction.fadeIn(withDuration: 1.0))
            duplicatedScreenShot.run(SKAction.fadeOut(withDuration: 1.0))
            
        case .defeated:
//            let blackAndWhiteFilter = CIFilter(name: "CIPhotoEffectTonal")
            let blackAndWhiteFilter = CIFilter(name: "CIColorMonochrome", parameters: ["inputColor" : CIColor.gray, "inputIntensity" : 0.0])
//            print(blackAndWhiteFilter)
            let blackAndWhiteEffectNode = SKEffectNode()
            blackAndWhiteEffectNode.filter = blackAndWhiteFilter
            planetsCard.addChild(blackAndWhiteEffectNode)
            planetsCard.screenShot.move(toParent: blackAndWhiteEffectNode)
            let fadeToBlackAndWhite = SKAction.customAction(withDuration: 1.0, actionBlock: { (node, time) in
                //(0, 0) (1, 1,0)
                let effectNode = node as! SKEffectNode
                effectNode.filter!.setValue(NSNumber(value: Float(time)), forKey: "inputIntensity")
            })
//            blackAndWhiteEffectNode.alpha = 0.8
            blackAndWhiteEffectNode.run(fadeToBlackAndWhite)
        }
        let scaleDown = SKAction.scale(to: 1.0, duration: 2.0)
        planetsCard.run(scaleDown)
        finalResultCard.showResult(result: result)
        self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run {
            self.switchCard(to: 7, isInstant: false)
            }]))
    }
}
