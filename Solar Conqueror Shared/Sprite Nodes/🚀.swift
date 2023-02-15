//
//  🚀.swift
//  Solar Conqueror
//
//  Created by exgphe on 16/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import SpriteKit

class 🚀: SKSpriteNode {
    
    static let rocketTexture = SKTexture(image: #imageLiteral(resourceName: "rocket.png"))
    static let rocketSize = CGSize(width: 8, height: 8)
    
    var owner : Owner
    
    init(owner: Owner, withFire: Bool = false) {
        self.owner = owner
        super.init(texture: 🚀.rocketTexture, color: owner.color(), size: 🚀.rocketSize)
        self.name = "rocket"
        self.colorBlendFactor = 1.0
        if withFire {
            let fire = SKEmitterNode(fileNamed: "rocketFire")!
            self.addChild(fire)
            fire.position = CGPoint(x: -4, y: -4)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func patrol(halfWidth:CGFloat) {
        let duration = 2.0
        let remainingTime = TimeInterval(CGFloat(duration/2.0)*(halfWidth-self.position.x)/halfWidth) // Because x position is random, the first patrol has to calculate the duration time contribution
//        print(remainingTime)
        let move1 = SKAction.moveTo(x: halfWidth, duration: duration)
        let move2 = SKAction.moveTo(x: -halfWidth, duration: duration)
        let rotate1 = SKAction.scale(to: -1.0, duration: 0.5)
        let rotate2 = SKAction.scale(to:1.0,duration: 0.5) // 2.5D rotation
        var presequence = [SKAction]()
        self.run(SKAction.rotate(byAngle: -CGFloat.pi/4.0, duration: 0))
        if(Bool.random()) {
            presequence = [SKAction.moveTo(x:halfWidth, duration:remainingTime),rotate1,SKAction.moveTo(x:-halfWidth, duration:duration),rotate2] // First go to right
        } else {
            presequence = [SKAction.scale(to: -1.0, duration: 0),SKAction.moveTo(x:-halfWidth, duration:duration-remainingTime),rotate2] // First go to left
        }
        self.run(SKAction.sequence([SKAction.sequence(presequence),SKAction.repeatForever(SKAction.sequence([move1,rotate1,move2,rotate2]))]))
    }
}

