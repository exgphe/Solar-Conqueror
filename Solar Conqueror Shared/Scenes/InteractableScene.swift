import SpriteKit
import AVFoundation

public class InteractableScene: SKScene {
    var planets = [PlanetNode]()
    
    var player : Player!
    var enemy : Enemy!
    
    var isSingleClickingToSelect = false // Other than dragging, another way to select planets
    
    var forceTouching = false
    var music: AVAudioPlayer!
    
    lazy var playerForceTouchSound:SKAudioNode = {
        let node = SKAudioNode(url: Bundle.main.url(forResource: "SpecialWeapon", withExtension: "m4a")!)
        node.autoplayLooped = false
        return node
    }()
    lazy var enemyForceTouchSound:SKAudioNode = {
        let node = SKAudioNode(url: Bundle.main.url(forResource: "SpecialWeapon", withExtension: "m4a")!)
        node.autoplayLooped = false
        return node
    }()
    
    var selectedPlanets:Array<PlanetNode> {
        get {
            var result  = [PlanetNode]()
            for planet in self.planets {
                if planet.selected {
                    result.append(planet)
                }
            }
            return result
        }
    }
    
    var pointingPlanet: PlanetNode? { // An enemy planet or Gaia planet where the user is targetting
        didSet {
            if let o = oldValue {
                o.pointed = false
            }
            if let p = pointingPlanet {
                p.pointed = true
            }
        }
    }
    
    var hoveringPlanet: PlanetNode? {
        didSet {
            if let o = oldValue {
                o.hovered = false
            }
            if let p = hoveringPlanet {
                p.hovered = true
            }
        }
    }
    
    override public func sceneDidLoad() {
        super.sceneDidLoad()
        scaleMode = .aspectFit
    }
    
#if os(macOS)
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if let planet = planetAtThisLocation(point: event.location(in: self)) {
            if planet.currentOwner == Owner.player {
                self.isSingleClickingToSelect = true
            }
        }
    }
    
    override public func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        //        print("dragged\(event.location(in: self))")
        //        print(self.nodes(at: event.location(in: self)))
        if let planet = planetAtThisLocation(point: event.location(in: self)) {
            selectAPlanet(planet: planet)
        } else {
            self.pointingPlanet = nil
        }
        self.isSingleClickingToSelect = false
    }
    
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        //        print("up\(String(describing: planetAtThisLocation(point: event.location(in: self)) ))")
        if let planet = planetAtThisLocation(point: event.location(in: self)) {
            if !self.forceTouching {
                if self.isSingleClickingToSelect {
                    //                print("ha2")
                    if self.selectedPlanets.isEmpty {
                        //                    print("ha3")
                        selectAPlanet(planet: planet)
                    } else {
                        //                    print("ha4")
                        player.moveComponent.send(from: selectedPlanets, to: planet)
                        self.deselectPlanets()
                    }
                } else {
                    player.moveComponent.send(from: selectedPlanets, to: planet)
                    self.deselectPlanets()
                }
            } else {
                self.forceTouching = false
            }
        } else {
            self.isSingleClickingToSelect = false
            self.deselectPlanets()
        }
        self.pointingPlanet = nil
        self.forceTouching = false
    }
    
    override public func mouseMoved(with event: NSEvent) {//Hovering a planet
        super.mouseMoved(with: event)
        if let planet = self.planetAtThisLocation(point: event.location(in: self)) {
            //            print("Hovered\(planet)")
            self.hoveringPlanet = planet
            if self.isSingleClickingToSelect && planet.currentOwner != Owner.player {
                self.pointingPlanet = planet
            }
        } else {
            self.pointingPlanet = nil
            self.hoveringPlanet = nil
        }
    }
    
    override public func pressureChange(with event: NSEvent) {
        if !self.forceTouching && event.stage == 2 {
            self.forceTouching = true
            if let planet = self.planetAtThisLocation(point: event.location(in: self)) {
                if planet.currentOwner == .enemy {
                    if player.specialWeaponsLeft > 0 {
                        player.specialWeaponsLeft -= 1
                        planet.forceTouched(location: event.location(in: planet))
                    } else {
                        planet.forceTouchFailed()
                    }
                } else {
                    planet.forceTouchFailed()
                }
            }
        }
    }
    
    override public func rightMouseUp(with event: NSEvent) {
        if let planet = self.planetAtThisLocation(point: event.location(in: self)) {
            if planet.currentOwner == .enemy {
                if player.specialWeaponsLeft > 0 {
                    player.specialWeaponsLeft -= 1
                    planet.forceTouched(location: event.location(in: planet))
                } else {
                    planet.forceTouchFailed()
                }
            } else {
                planet.forceTouchFailed()
            }
        }
    }
#endif
    
#if os(iOS)
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 {
            if let touch = touches.first,
               let planet = planetAtThisLocation(point: touch.location(in: self)) {
                if planet.currentOwner == Owner.player {
                    self.isSingleClickingToSelect = true
                }
            }
        } else {
            // TODO multi-touch
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            let translation = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
            if translation == CGPoint.zero {
                continue
            }
            if let planet = planetAtThisLocation(point: touch.location(in: self)) {
                selectAPlanet(planet: planet)
            } else {
                self.pointingPlanet = nil
            }
            self.isSingleClickingToSelect = false
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //        print("up\(String(describing: planetAtThisLocation(point: event.location(in: self)) ))")
        guard let touch = touches.first else {return} // TODO handle multitouch
        if let planet = planetAtThisLocation(point: touch.location(in: self)) {
            if !self.forceTouching {
                if self.isSingleClickingToSelect {
                    //                print("ha2")
                    if self.selectedPlanets.isEmpty {
                        //                    print("ha3")
                        selectAPlanet(planet: planet)
                    } else {
                        //                    print("ha4")
                        player.moveComponent.send(from: selectedPlanets, to: planet)
                        self.deselectPlanets()
                    }
                } else {
                    player.moveComponent.send(from: selectedPlanets, to: planet)
                    self.deselectPlanets()
                }
            } else {
                self.forceTouching = false
            }
        } else {
            self.isSingleClickingToSelect = false
            self.deselectPlanets()
        }
        self.pointingPlanet = nil
        self.forceTouching = false
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.deselectPlanets()
        self.pointingPlanet = nil
        self.isSingleClickingToSelect = false
    }
    
#endif
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        self.player = Player(scene: self)
        self.enemy = Enemy(scene: self)
        addChild(playerForceTouchSound)
        addChild(enemyForceTouchSound)
        playerForceTouchSound.autoplayLooped = false
        enemyForceTouchSound.autoplayLooped = false
    }
    
    override public func update(_ currentTime: TimeInterval) {
        if self.pointingPlanet?.currentOwner == .player { //Shouldn't attack own planets
            self.pointingPlanet!.selected = true
            self.pointingPlanet = nil
        }
    }
    
    func planetAtThisLocation(point:CGPoint) -> PlanetNode? {
        let nodes = self.nodes(at: point)
        //        print("nodes\(nodes)")
        for n in nodes {
            //            print(n as! PlanetNode)
            if let p = n as? PlanetNode {
                let realSize = p.size
                // Detecting whether the mouse is really on the planet, not on its children like text labels
                //(-145.0, -80.7344284057617)
                //(1310.0, -161.468856811523)
                //(1443.6171875, -90.1210861206055)
                
                if abs(p.position.x - point.x) <= realSize.width / 2 && abs(p.position.y - point.y) <= realSize.height / 2 {
                    return p
                }
            }
        }
        return nil
    }
    
    func selectAPlanet(planet:PlanetNode) {
        switch(planet.currentOwner) {
        case .player:
            if !planet.isForceTouched {
                planet.selected = true
                self.pointingPlanet = nil
            }
        default:
            if !self.selectedPlanets.isEmpty {
                self.pointingPlanet = planet
            }
        }
    }
    
    func deselectPlanets() {
        for planet in self.planets {
            planet.selected = false
        }
        self.isSingleClickingToSelect = false
    }
    
    func createRocketArmy(from: PlanetNode, to: PlanetNode, number: Int, performer: Owner) {
        //        let travelX = differenceX > 0 ? differenceX - to.size.width * 0.5 : differenceX + to.size.width * 0.5
        //        let travelY = differenceY > 0 ? differenceY - to.size.height * 0.5 : differenceY + to.size.height * 0.5
        let originalFromPosition: CGPoint
        let originalToPosition: CGPoint
        if from.scene! is CardsScene {
            originalFromPosition = CGPoint(x: from.position.x + from.parent!.position.x, y: from.position.y + from.parent!.position.y)
            originalToPosition = CGPoint(x: to.position.x + to.parent!.position.x, y: to.position.y + to.parent!.position.y)
        } else {
            originalFromPosition = from.position
            originalToPosition = to.position
        }
        for i in 0..<number {
            let fromPosition = CGPoint(x:originalFromPosition.x + CGFloat.random(in: -from.size.width * 0.25...from.size.width*0.25), y:originalFromPosition.y + CGFloat.random(in: -from.size.height*0.15...from.size.height*0.15))
            //  print(fromPosition)
            let toPosition = CGPoint(x:originalToPosition.x + CGFloat.random(in: -to.size.width * 0.05...to.size.width * 0.05), y:originalToPosition.y + CGFloat.random(in: -to.size.height * 0.05...to.size.height * 0.05))
            let differenceX = toPosition.x - fromPosition.x
            let differenceY = toPosition.y - fromPosition.y
            let travelTime = TimeInterval(sqrt(pow(differenceX, 2) + pow(differenceY, 2)) * 0.01)
            //        print(travelTime)
            let angle = atan(differenceY / differenceX) - (CGFloat.pi / 4) + (differenceX < 0 ? CGFloat.pi : 0)
            let march = SKAction.moveBy(x: differenceX, y: differenceY, duration: travelTime)
            let attack = SKAction.run {
                let playSound = (i % 4 == 0)
                to.relatedEntity.rocketArrivedFrom(origin: performer, playSound: playSound)
            }
            let rocket = 🚀(owner: performer, withFire: true)
            self.addChild(rocket)
            rocket.position = fromPosition
            let sequence = [SKAction.hide(), SKAction.wait(forDuration: Double(i) * 0.1), SKAction.rotate(toAngle: angle, duration: 0), SKAction.unhide(), march, attack, SKAction.removeFromParent()]
            rocket.run(SKAction.sequence(sequence))
        }
    }
    
    
    
}
