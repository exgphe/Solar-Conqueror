import Foundation
import SpriteKit
import AVFoundation

class LightningNode: SKSpriteNode {
    
    var targetPoints = [CGPoint]();
    var startPoint: CGPoint!
    
    // Time between bolts (in seconds)
    let timeBetweenBolts = 0.15
    
    let period = 0.8
    
    // Bolt lifetime (in seconds)
    let boltLifetime = 0.15
    
    // Line draw delay (in seconds). Set as 0 if you want whole bolt to draw instantly
    let lineDrawDelay = 0.00175
    
    // 0.0 - the bolt will be a straight line. >1.0 - the bolt will look unnatural
    let displaceCoefficient = 0.25
    
    // Make bigger if you want bigger line lenght and vice versa
    let lineRangeCoefficient = 2.0
    
    var performer: Owner!
    
    // MARK: - Life cycle

    init(size: CGSize, startPoint: CGPoint, performer: Owner) {
        self.performer = performer
        super.init(texture: nil, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0), size: size)
        self.size = size
        self.startPoint = startPoint
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Lightning operating
    
    func startLightning() {
        let wait = SKAction.wait(forDuration: timeBetweenBolts)
        let addLightning = SKAction.run { () -> Void in
            for targetPoint in self.targetPoints {
                self.addBolt(self.startPoint, endPoint: targetPoint)
            }
        }
        let makeRandomTargets = SKAction.run {
            let numbers: Int
            switch self.size.width {
            case 0..<60:
                numbers = Int.random(in: 10...20) // 10~20
            case 60..<200:
                numbers = Int.random(in: 20...30) // 20~30
            default:
                numbers = Int.random(in: 40...50) // 40~50
            }
            for _ in 0..<numbers {
                let rayon = self.size.height / 2.0
                let randomAngle = Double.random(in: 0...2*Double.pi)
                //                let randomX = CGFloat(arc4random_uniform(UInt32(self.size.width) * 10)) / 10.0 - self.size.width * 0.5
                //                let randomY = CGFloat(arc4random_uniform(UInt32(self.size.height) * 10)) / 10.0 - self.size.height * 0.5
                //                if self.startPoint != nil {
                let randomX = rayon * cos(randomAngle)
                let randomY = rayon * sin(randomAngle)
                self.targetPoints.append(CGPoint(x: randomX, y: randomY))
                //                } else {
                //                    self.startPoint = CGPoint(x: randomX, y: randomY)
                //                }
            }
        }
        let removePreviousTargets = SKAction.run {
            self.targetPoints.removeAll()
            //            self.startPoint = nil
        }
        switch performer! {
        case .enemy:
            (self.scene as? InteractableScene)?.playerForceTouchSound.run(SKAction.play())
        case .player:
            (self.scene as? InteractableScene)?.enemyForceTouchSound.run(SKAction.play())
        default:
            break
        }
        
        let periodicFlash = SKAction.sequence([addLightning, wait])
        self.run(SKAction.repeatForever(SKAction.sequence([makeRandomTargets, SKAction.fadeIn(withDuration: 0.05), SKAction.repeat(periodicFlash, count: Int(period / timeBetweenBolts)), removePreviousTargets, SKAction.fadeOut(withDuration: 0.2)])), withKey: "lightning")
        //        self.run(makeRandomTargets)
        //        self.run(SKAction.repeatForever(SKAction.sequence([addLightning, wait])), withKey: "lightning")
    }
    
    func stopLightning() {
        self.removeAction(forKey: "lightning")
        self.removeFromParent()
    }
    
    func addBolt(_ startPoint: CGPoint, endPoint: CGPoint) {
        let bolt = LightningBoltNode(startPoint: startPoint, endPoint: endPoint, lifetime: self.boltLifetime, lineDrawDelay: self.lineDrawDelay, displaceCoefficient: self.displaceCoefficient, lineRangeCoefficient: self.lineRangeCoefficient, performer: self.performer)
        self.addChild(bolt)
    }
}
