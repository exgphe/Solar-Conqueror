//
//  PlanetNode.swift
//  Solar Conqueror
//
//  Created by exgphe on 14/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import SpriteKit
import GameplayKit

public class PlanetNode: SKSpriteNode {
    public var selected = false {
        didSet {
            if selected != oldValue {
                if selected {
                    self.addChild(self.planetCircle(alpha: 1,called:"MyCircle",with:#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
                    //                    print(self.distanceTo)
                } else {
                    self.childNode(withName: "MyCircle")?.removeFromParent()
                    //                    print("deselected this planet")
                    //                    print(self.children)
                }
            }
        }
    }
    
    public var pointed = false {
        didSet {
            if pointed != oldValue {
                if pointed {
                    self.addChild(self.planetCircle(alpha: 1,called:"EnemyCircle",with:#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)))
                } else {
                    self.childNode(withName: "EnemyCircle")?.removeFromParent()
                }
            }
        }
    }
    
    public var hovered = false {
        didSet {
            if hovered != oldValue {
                if hovered {
                    self.addChild(self.planetCircle(alpha: 0.5,called: "HoverCircle"))
                } else {
                    self.childNode(withName: "HoverCircle")?.removeFromParent()
                }
            }
            //            self.label.run(SKAction(named: "giggle", from: Bundle.main.url(forResource: "MyActions", withExtension: "sks")!)!)
        }
    }
    public var currentOwner = Owner.gaia {
        didSet {
            if currentOwner != oldValue {
                self.label?.fontColor = currentOwner.color()
                self.giggleText()
                self.enumerateChildNodes(withName: "rocket") { (node, _) in
                    let rocket = node as! 🚀
                    rocket.color = self.currentOwner.color()
                }
                switch currentOwner {
                case .enemy :
                    self.selected = false
                case .player:
                    self.pointed = false
                default:
                    break
                }
            }
        }
    }
    public var population = 0 {
        didSet {
            self.updateTextLabel()
            let delta = population - oldValue
            if delta > 0 {
                for _ in 1...delta {
                    self.addRocket()
                }
            } else {
                var i = -delta
                self.enumerateChildNodes(withName: "rocket") { (node, stop) in
                    node.removeFromParent()
                    i-=1
                    if i<=0 {
                        stop.initialize(to: true)
                    }
                }
            }
        }
    }
    public var limit:Int {
        return Limits[self.name!] ?? 0
    }
    
    public var isForceTouched = false
    
    public lazy var relatedEntity:PlanetEntity = {
        return PlanetEntity(relatedNode: self)
    }()
    
    var label:SKLabelNode? {
        return self.childNode(withName: "Label") as? SKLabelNode
    }
    
    var distanceTo = [PlanetNode:CGFloat]() // So that intelligence component can refer to this without calculating each time when evaluating
    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.setValue(0, forKey: "population") // Why shouldn't it simply be self.population = 0 ???
//    }
    
    override public var description: String {
        return self.name!
    }
    
    func updateTextLabel() {
        let horror = self.isForceTouched ? "😱" : ""
        let fullPopulated = self.population == self.limit ? "⚠️" : ""
        let overPopulated = self.population > self.limit ? "❗️" : ""
        self.label?.text = "\(horror)\(fullPopulated)\(overPopulated)\(self.population)/\(self.limit)"
    }
    
    func planetCircle(alpha: CGFloat = 1.0,called name:String,with color: SKColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) -> SKShapeNode {
        let circleNode = SKShapeNode(circleOfRadius: self.size.height / 2)//Cannot be width because Saturn...
        circleNode.alpha = alpha
        circleNode.lineWidth = 2.0
        circleNode.glowWidth = 1.0
        circleNode.strokeColor = color
        circleNode.name = name
        return circleNode
    }
    
    func addRocket() {
        let rocket = 🚀(owner: self.currentOwner)
        self.addChild(rocket)
        rocket.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.frame.height*10)))/10.0-self.frame.height/2.0, y: CGFloat(arc4random_uniform(UInt32(self.frame.height*3)))/10.0-self.frame.height*0.15) // To make the rocket position random at all x and 40% of y
        //        print(rocket.position)
        rocket.patrol(halfWidth: self.frame.height / 2)
        
    }
    
    func blink() {
        self.run(SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.1),SKAction.fadeAlpha(to: 1.0, duration: 0.1)]),count: 3))
    }
    
    func giggleText() {
        self.label?.run(SKAction.sequence([SKAction.scale(to: 2.5, duration: 0.4),SKAction.scale(to: 1.0, duration: 0.4)]))
    }
    
    func explode(playSound: Bool) {
        let explosion = SKEmitterNode(fileNamed: "Explosion.sks")!
//        let light = SKLightNode()
//        light.categoryBitMask = 2
//        light.falloff = 2
        self.addChild(explosion)
//        explosion.addChild(light)
        let x = CGFloat(arc4random_uniform(UInt32(self.size.width))) - self.size.width / 2
        let y = CGFloat(arc4random_uniform(UInt32(self.size.height * 3)))/10.0 - self.size.height * 0.15
        explosion.position = CGPoint(x: x, y: y)
        explosion.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),SKAction.removeFromParent()]))
        if playSound {
            let boomNum = arc4random_uniform(9)
            self.run(SKAction.playSoundFileNamed("boom\(boomNum)", waitForCompletion: false))
        }
    }
    
    func forceTouched(location: CGPoint) {
        self.isForceTouched = true
        var performer: Owner!
        switch self.currentOwner {
        case .enemy:
            performer = .player
        case .player:
            performer = .enemy
        default:
            break
        }
        self.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.2),SKAction.scale(to: 1.0, duration: 0.2)]))
            let lightning = LightningNode(size: self.size, startPoint: location, performer: performer)
            lightning.name = "ftLightning"
            self.addChild(lightning)
            lightning.startLightning()
        self.updateTextLabel()
        //black out
        self.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.colorBlendFactor = 0.7
        // have a circle
        //        let circle = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "spark.png")))
        //        circle.size = CGSize.zero
        //        circle.name = "ftCircle"
        //        circle.zPosition = 50.0
        //        self.addChild(circle)
        //        circle.position = location
        //        let circleFinalSize = CGSize(width: self.size.width / 2.0, height: self.size.height / 2.0)
        //        circle.run(SKAction.scale(to: circleFinalSize, duration: 0.1))
        let duration = 10.0
        self.scene!.enumerateChildNodes(withName: "/rocket") { (node, _) in
            if node.intersects(self) && node.isHidden { // Some rockets to be send
                let rocket = node as! 🚀
                if rocket.owner == self.currentOwner {
                    self.population += 1
                }
                rocket.removeFromParent()
            }
        }
        self.enumerateChildNodes(withName: "rocket") { (node,_) in
            node.isPaused = true
            let rocket = node as! SKSpriteNode
            rocket.colorBlendFactor = 0.5
            rocket.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        if name == "Sun" {
            scene?.childNode(withName: "/sunshine")?.isPaused = true
        }
        let revert = SKAction.run {
            self.cancelForceTouch()
        }
        self.run(SKAction.sequence([SKAction.wait(forDuration: duration),revert]), withKey: "revertForceTouch")
    }
    
    func cancelForceTouch() {
        if let lightning = self.childNode(withName: "ftLightning") as? LightningNode {
//            lightning.sound.removeAllActions()
//            lightning.sound.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
//            lightning.sound.run(SKAction.pause())
//            lightning.sound.run(SKAction.stop())
//            lightning.sound.removeFromParent()
            if let scene = scene as? InteractableScene {
                switch lightning.performer! {
                case .enemy:
                    scene.enemyForceTouchSound.removeAllActions()
                    scene.enemyForceTouchSound.run(SKAction.changeVolume(to:0.0, duration: 0.0))
                    scene.enemyForceTouchSound.run(SKAction.pause())
                    scene.enemyForceTouchSound.run(SKAction.stop())
                case .player:
                    scene.playerForceTouchSound.removeAllActions()
                    scene.playerForceTouchSound.run(SKAction.changeVolume(to:0.0, duration: 0.0))
                    scene.playerForceTouchSound.run(SKAction.pause())
                    scene.playerForceTouchSound.run(SKAction.stop())
                default:
                    break
                }
            }
            lightning.removeFromParent()
        }
        self.childNode(withName: "ftCircle")?.removeFromParent()
        self.colorBlendFactor = 0.0
        self.enumerateChildNodes(withName: "rocket") { (node,_) in
            node.isPaused = false
            let rocket = node as! SKSpriteNode
            rocket.colorBlendFactor = 1.0
            rocket.color = self.currentOwner.color()
        }
        self.isForceTouched = false
        if name == "Sun" {
            scene?.childNode(withName: "/sunshine")?.isPaused = false
        }
        self.updateTextLabel()
    }
    
    func forceTouchFailed() {
        self.run(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1), SKAction.scale(to: 1.2, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1), SKAction.scale(to: 1.1, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1)]))
    }
}

