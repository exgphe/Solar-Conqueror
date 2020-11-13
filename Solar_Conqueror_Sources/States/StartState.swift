import GameplayKit
import SpriteKit

class StartState: PlanetSceneState {
    override func didEnter(from previousState: GKState?) {
        // Some animations, dialogs
        let startGame = SKAction.run {
            self.stateMachine?.enter(NormalState.self)
        }
        self.scene.run(SKAction.sequence([SKAction.wait(forDuration: 5.0), startGame]))
    }
}
