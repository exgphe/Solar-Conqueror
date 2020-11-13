import GameplayKit

public class PlanetEntity: GKEntity {
    
    var node: PlanetNode
    
    init(relatedNode: PlanetNode) {
        //        print("inited \(relatedNode)")
        self.node = relatedNode
        super.init()
        //        print(self.node)
        if relatedNode.scene! is PlanetsScene {
            self.addComponent(Spawner())
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rocketArrivedFrom(origin: Owner, playSound: Bool) {
        if self.node.currentOwner == Owner.gaia { // Personne
            self.node.currentOwner = origin
            self.node.population += 1
        } else if self.node.currentOwner != origin { // Ennemi
            if self.node.population > 0 { // Still rockets there
                self.node.population -= 1
            } else { // Change owner
                self.node.currentOwner = origin
                if self.node.isForceTouched {
                    self.node.removeAction(forKey: "revertForceTouch")
                    self.node.cancelForceTouch()
                }
                self.node.population += 1
            }
            self.node.explode(playSound: playSound)
        } else {// Ami
            if self.node.isForceTouched {
                self.node.explode(playSound: playSound)
            } else {
                self.node.population += 1
            }
            
        }
    }
}

