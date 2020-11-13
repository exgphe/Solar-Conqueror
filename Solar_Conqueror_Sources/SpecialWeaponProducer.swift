//
//  SpecialWeaponProducer.swift
//  Solar_Conqueror_Sources
//
//  Created by Xiaolin Wang on 24/03/2019.
//  Copyright © 2019 Xiaolin Wang. All rights reserved.
//

import GameplayKit

class SpecialWeaponProducer: GKComponent {
    var timeToLastProduction: TimeInterval = 0.0
    let produceTimeInterval : TimeInterval = 30.0
    
    var me: Role {
        return self.entity as! Role
    }
    
    lazy var tada: SKAction = {
        let smaller = SKAction.scale(to: 0.9, duration: 0.1)
        let bigger = SKAction.scale(to: 1.1, duration: 0.1)
        let normal = SKAction.scale(to: 1.0, duration: 0.1)
        let clockwise = SKAction.rotate(toAngle: 0.05, duration: 0.1)
        let counterclockwise = SKAction.rotate(toAngle: -0.05, duration: 0.1)
        let normalAngle = SKAction.rotate(toAngle: 0.0, duration: 0.1)
        return SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            smaller,
            SKAction.group([bigger, clockwise]),
            counterclockwise,
            clockwise,
            counterclockwise,
            clockwise,
            counterclockwise,
            clockwise,
            SKAction.group([normal, normalAngle])
            ])
    }()
 
    let relatedLabelName: String?
    var relatedLabel: SKLabelNode?
    var originalLabelPosition: CGPoint?
 
    func produce() {
        self.me.specialWeaponsLeft += 1
        timeToLastProduction = 0.0
        if self.me.specialWeaponsLeft >= maximumSpecialWeaponAmount {
            if let label = self.relatedLabel {
                label.text = "𝗙𝗢𝗥𝗖𝗘 available!"
                label.fontSize = 36.0
                let newWidth = label.frame.width
                label.horizontalAlignmentMode = .center
                label.position.x = label.position.x  + newWidth / 2.0
                label.fontColor = #colorLiteral(red: 0.9529411765, green: 0.337254902, blue: 0.1490196078, alpha: 1)
                label.alpha = 1.0
                // let effect = SKEffectNode()
                // let filter = CIFilter(name: "CIHueAdjust", withInputParameters: ["inputAngle" : 0.00])
                // effect.filter = filter
                // let parent = label.parent!
                // parent.addChild(effect)
                // effect.position = label.position
                // effect.move(toParent: parent)
                // label.move(toParent: effect)
                //let changeColor = SKAction.customAction(withDuration: 5.0, actionBlock: { (node, time) in
                 //   //(0, 0) (5, 2pi)
                //    (node as! SKEffectNode).filter?.setValue(time * 0.4 * CGFloat.pi, forKey: "inputAngle")
                //})
                // effect.run(SKAction.repeatForever(changeColor))
                label.run(SKAction.repeatForever(tada))
                label.run(SKAction.playSoundFileNamed("ForceAvailable.m4a", waitForCompletion: false))
            }
        }
    }
    
    func removeLabelEffect() {
        if let label = self.relatedLabel {
            label.removeAllActions()
            // let effect = label.parent!
            // let parent = effect.parent!
            // label.move(toParent: parent)
            // effect.removeFromParent()
            label.horizontalAlignmentMode = .left
            label.fontSize = 24.0
            label.position = self.originalLabelPosition!
            label.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            label.alpha = 0.7
            label.zRotation = 0.0
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if self.me.specialWeaponsLeft < maximumSpecialWeaponAmount {
            timeToLastProduction += seconds
            if timeToLastProduction >= produceTimeInterval {
                produce()
            } else {
                self.relatedLabel?.text = "Next 𝗙𝗢𝗥𝗖𝗘 in \(Int(ceil(self.produceTimeInterval - self.timeToLastProduction))) seconds"
            }
        }
    }
    
    override func didAddToEntity() {
        if self.relatedLabelName != nil {
            self.relatedLabel = self.me.scene.childNode(withName: "TextLabels/\(self.relatedLabelName!)") as? SKLabelNode
            self.originalLabelPosition = self.relatedLabel?.position
        }
        
    }
    
    init(relatedLabelName: String?) {
        self.relatedLabelName = relatedLabelName
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
