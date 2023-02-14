import GameplayKit

class Spawner: GKComponent {
    
    var timeToLastSpawn: TimeInterval = 0.0
    var spawnInterval:TimeInterval {
        return spawnIntervalFor[self.node.name!]!
    }
    
    var node:PlanetNode!
    
    func spawn() {
        if node.currentOwner != Owner.gaia {
            if node.population < node.limit {
                node.population += 1
            }
        }
        timeToLastSpawn = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        //        print("deltaTime\(seconds)")
        timeToLastSpawn += seconds
        if timeToLastSpawn >= spawnInterval {
            if !self.node.isForceTouched {
                spawn()
            }
        }
    }
    
    override func didAddToEntity() {
//        print(self.entity!)
        let father = self.entity! as! PlanetEntity
        self.node = father.node
    }
}

