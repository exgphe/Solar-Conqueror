import GameplayKit

class FailState: PlanetSceneState {
    override func didEnter(from previousState: GKState?) {
//        print("failed")
        self.scene.music.setVolume(0.0, fadeDuration: 0.5)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.scene.music.stop()
            (self.scene.view as! GameView).goToFailure(background: self.scene.childNode(withName: "background"))
        })
        
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is StartState.Type
    }
}
