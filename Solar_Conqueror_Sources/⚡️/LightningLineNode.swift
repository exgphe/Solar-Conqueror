import SpriteKit

class LightningLineNode: SKNode {
    var startPoint = CGPoint(x: 0.0, y: 0.0)
    var endPoint = CGPoint(x: 0.0, y: 0.0)
    let thickness = CGFloat(0.3)
    
    static let sHalfCircle: SKTexture = SKTexture(imageNamed: "half_circle")
    static let sHalfCircleEnemy: SKTexture = SKTexture(imageNamed: "half_circle_enemy")
    
    static let sLightningSegment:SKTexture = SKTexture(imageNamed: "lightning_segment")
    static let sLightningSegmentEnemy:SKTexture = SKTexture(imageNamed: "lightning_segment_enemy")
    
    var halfCircle: SKTexture!
    var lightningSegment: SKTexture!
    
    init(startPoint: CGPoint, endPoint: CGPoint, performer: Owner) {
        switch performer {
        case .enemy:
            self.halfCircle = LightningLineNode.sHalfCircleEnemy
            self.lightningSegment = LightningLineNode.sLightningSegmentEnemy
        case .player:
            self.halfCircle = LightningLineNode.sHalfCircle
            self.lightningSegment = LightningLineNode.sLightningSegment
        default:
            break
        }
        super.init()
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func draw() {
        let startPointInThisNode = self.convert(self.startPoint, from: self.parent!)
        let endPointInThisNode = self.convert(self.endPoint, from: self.parent!)
        
        let angle = CGFloat(atan2(Float(endPointInThisNode.y) - Float(startPointInThisNode.y),
                                  Float(endPointInThisNode.x) - Float(startPointInThisNode.x)));
        let length = hypotf(fabsf(Float(endPointInThisNode.x) - Float(startPointInThisNode.x)),
                            fabsf(Float(endPointInThisNode.y) - Float(startPointInThisNode.y)))
        
        let halfCircleA = SKSpriteNode(texture: self.halfCircle)
        halfCircleA.anchorPoint = CGPoint(x: 1, y: 0.5)
        let halfCircleB = SKSpriteNode(texture: self.halfCircle)
        halfCircleB.anchorPoint = CGPoint(x: 1, y: 0.5)
        halfCircleA.xScale = thickness
        halfCircleB.xScale = -thickness
        let lightningSegment = SKSpriteNode(texture: self.lightningSegment)
        halfCircleA.yScale = thickness
        halfCircleB.yScale = thickness
        //        lightningSegment.yScale =
        halfCircleA.zRotation = angle
        halfCircleB.zRotation = angle
        lightningSegment.zRotation = angle
        lightningSegment.xScale = CGFloat(length / 36.0)
        lightningSegment.yScale = thickness
        
        halfCircleA.alpha = 0.3
        halfCircleB.alpha = 0.3
        halfCircleA.blendMode = .alpha
        halfCircleB.blendMode = .alpha
        lightningSegment.blendMode = .alpha
        
        halfCircleA.position = startPointInThisNode
        halfCircleB.position = endPointInThisNode
        lightningSegment.position = CGPoint(x: (startPointInThisNode.x + endPointInThisNode.x)*0.5, y: (startPointInThisNode.y + endPointInThisNode.y)*0.5)
        self.addChild(halfCircleA)
        self.addChild(halfCircleB)
        self.addChild(lightningSegment)
    }
}
