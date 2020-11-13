import GameplayKit

class Role: GKEntity {
    var scene: InteractableScene!
    let moveComponent: MoveShips
    var identity = Owner.gaia
    
    var specialWeaponProducer: SpecialWeaponProducer?
    var specialWeaponsLeft = 0 {
        didSet {
            if specialWeaponsLeft < oldValue {
                self.specialWeaponProducer?.removeLabelEffect()
            }
        }
    }
    
    var ownedPlanets: [PlanetNode] {
        var result = [PlanetNode]()
        for planet in self.scene.planets {
            if planet.currentOwner == self.identity {
                result.append(planet)
            }
        }
        return result
    }
    
    init(scene: InteractableScene) {
        self.scene = scene
        self.moveComponent = MoveShips()
        super.init()
        self.addComponent(self.moveComponent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

