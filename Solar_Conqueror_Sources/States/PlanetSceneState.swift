import GameplayKit

class PlanetSceneState: GKState {
    let scene: PlanetsScene
    init(scene: PlanetsScene) {
        self.scene = scene
        super.init()
    }
}
