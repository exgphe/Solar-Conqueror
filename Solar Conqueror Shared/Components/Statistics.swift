import GameplayKit

class Statistics: GKComponent {
    
    let indicatorName: String
    var indicator: PopulationIndicator!
    
    var me: Role {
        return self.entity as! Role
    }
    
    var totalPopulation: Int {
        var population = 0
        for planet in me.ownedPlanets {
            population += planet.population
        }
        self.me.scene.enumerateChildNodes(withName: "/rocket") { (node, _) in
            let rocket = node as! 🚀
            if rocket.owner == self.me.identity {
                population += 1
            }
        }
        return population
    }
    
    var totalLimit: Int {
        var limit = 0
        for planet in me.ownedPlanets {
            limit += planet.limit
        }
        return limit
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.indicator.population = self.totalPopulation
        self.indicator.limit = self.totalLimit
        //Detect win/lose
        if self.totalPopulation == 0 && self.totalLimit == 0 {
            if let scene = self.me.scene as? PlanetsScene {
                switch self.me.identity {
                case .enemy:
                    scene.stateMachine.enter(VictoryState.self)
                case .player:
                    scene.stateMachine.enter(FailState.self)
                default:
                    break
                }
            }
        }
    }
    
    override func didAddToEntity() {
        self.indicator = me.scene.childNode(withName: "TextLabels/\(self.indicatorName)") as? PopulationIndicator
        self.indicator.color = me.identity.color()
    }
    
    init(indicatorName: String) {
        self.indicatorName = indicatorName
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

