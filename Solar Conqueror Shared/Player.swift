import Foundation
import GameplayKit

class Player: Role {
    override init(scene: InteractableScene) {
        super.init(scene: scene)
        self.identity = Owner.player
        if scene is PlanetsScene {
            self.addComponent(Statistics(indicatorName: "PlayerPopulationIndicator"))
            let producer = SpecialWeaponProducer(relatedLabelName: "forceLabel")
            self.specialWeaponProducer = producer
            self.addComponent(producer)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
