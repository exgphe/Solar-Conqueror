//
//  FinalResultCard.swift
//  Solar_Conqueror_Sources
//
//  Created by Xiaolin Wang on 24/03/2019.
//  Copyright © 2019 Xiaolin Wang. All rights reserved.
//

import SpriteKit
import AVFoundation

class FinalResultCard: Card {
    lazy var victoryResult: SKNode = {
        return self.childNode(withName: "VictoryResult")!
    }()
    
    lazy var defeatedResult: SKNode = {
        return self.childNode(withName: "DefeatedResult")!
    }()
    
    lazy var replayButton: SKLabelNode = {
        return self.childNode(withName: "replay") as! SKLabelNode
    }()
    
    lazy var exitButton: SKLabelNode = {
        return self.childNode(withName: "exit")  as! SKLabelNode
    }()
    
    lazy var firework: SKEmitterNode = {
        return self.childNode(withName: "//FireworkParticles") as! SKEmitterNode
    }()
    
    var title: SKLabelNode?
    
    override var vibrantButtons: [SKNode] {
        return [self.replayButton, self.exitButton]
    }
    
    override func mouseMovedFromScene(nodes: [SKNode]) {
        super.mouseMovedFromScene(nodes: nodes)
    }
    
    override func mouseDownFromScene(nodes: [SKNode]) {
        super.mouseDownFromScene(nodes: nodes)
    }
    
    override func mouseUpFromScene(nodes: [SKNode]) {
        super.mouseUpFromScene(nodes: nodes)
        if nodes.contains(self.replayButton) {
            // replay
            let cardsScene = self.scene as! CardsScene
            let planetCard = cardsScene.cards[planetCardIndex] as! PlanetsCard
            planetCard.fakePlanetsScene.isHidden = false
            planetCard.screenShot.isHidden = true
            cardsScene.switchCard(to: planetCardIndex, isInstant: false)
            self.delayTransitionToPlanetsScene()
        }
        else if nodes.contains(self.exitButton) {
           // return to first page
            let cardsScene = self.scene as! CardsScene
            cardsScene.switchCard(to: 0, isInstant: false)
            self.run(SKAction.wait(forDuration: 2.0), completion: {
                let planetCard = cardsScene.cards[planetCardIndex] as! PlanetsCard
                planetCard.fakePlanetsScene.isHidden = false
                planetCard.screenShot.isHidden = true
            })
        }
    }
    
    override func switchedOn() {
        self.exitButton.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
        self.exitButton.colorBlendFactor = 1.0
        self.replayButton.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
        self.replayButton.colorBlendFactor = 1.0
        // print(self.frame)
    }
    
    override func switchedOff() {
        self.title?.run(SKAction.stop())
    }
    
    func showResult(result: resultType) {
        switch result {
        case .victory:
            self.victoryResult.isHidden = false
            self.defeatedResult.isHidden = true
            // Have some firework
            let realFrame = self.calculateAccumulatedFrame()
            let randomPosition = SKAction.run {
                let x = CGFloat(arc4random_uniform(UInt32(realFrame.width * 10.0))) / 10.0 - realFrame.width / 2.0
                let y = CGFloat(arc4random_uniform(UInt32(realFrame.height * 10.0))) / 10.0 - realFrame.height / 2.0
                
                self.firework.particlePosition = CGPoint(x: x, y: y)
            }
            self.firework.run(SKAction.sequence([SKAction.hide(), SKAction.wait(forDuration: 2.7), SKAction.unhide(), SKAction.repeatForever(SKAction.sequence([randomPosition, SKAction.wait(forDuration: 0.6)]))]))
            // Text animation
            self.title = self.childNode(withName: ".//VictoryTitle") as? SKLabelNode
            let giggles = SKAction.repeat(SKAction.group([SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)]), SKAction.sequence([SKAction.fadeAlpha(to: 0.6, duration: 0.3), SKAction.fadeAlpha(to: 1, duration: 0.3)])]), count: 5)
            let playVictoryMusic = SKAction.run {
                do {
                    let cardsScene = self.scene as! CardsScene
                    try cardsScene.music = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Victory", withExtension: "m4a")!)
                    cardsScene.music.prepareToPlay()
                    cardsScene.music.play()
                } catch {
                    print("...")
                }
            }
            title?.run(SKAction.sequence([SKAction.wait(forDuration: 2.7), playVictoryMusic, giggles]))
        case .defeated:
            self.victoryResult.isHidden = true
            self.defeatedResult.isHidden = false
            // Text animation
            self.title = self.childNode(withName: ".//DefeatedTitle") as? SKLabelNode
            title?.color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            title?.colorBlendFactor = 0.0
            let changeColor = SKAction.customAction(withDuration: 1.0, actionBlock: { (node, time) in
                (node as! SKLabelNode).colorBlendFactor = time
            })
            let playDefeatedMusic = SKAction.run {
                do {
                    let cardsScene = self.scene as! CardsScene
                    try cardsScene.music = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Defeated", withExtension: "m4a")!)
                    cardsScene.music.prepareToPlay()
                    cardsScene.music.play()
                } catch {
                    print("...")
                }
            }
            title?.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), playDefeatedMusic, SKAction.group([SKAction.sequence([SKAction.scale(to: 1.5, duration: 1.0), SKAction.scale(to: 1.0, duration: 1.0)]), changeColor])]))
        }
    }
}
