import GameplayKit

class MoveShips: GKComponent {
    var scene: InteractableScene!
    var father: Role {
        return self.entity as! Role
    }
    func send(from start :[PlanetNode],to target: PlanetNode) {
        if !(target.isForceTouched && target.currentOwner == self.father.identity) {
            var sources = start
            if let index = start.firstIndex(of: target) {
                sources.remove(at: index)
            }
            for planet in sources {
                if !planet.isForceTouched {
                    let number = planet.population / 2
                    planet.population -= number
                    self.scene.createRocketArmy(from: planet, to: target, number: number, performer: self.father.identity)
                }
            }
            if !sources.isEmpty && self.father.identity == Owner.player {
                target.blink()
            }
        }
    }
    
    override func didAddToEntity() {
            self.scene = father.scene
    }
}

