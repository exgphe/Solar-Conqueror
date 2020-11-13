import GameplayKit
import AVFoundation

class NormalState: PlanetSceneState {
    override func didEnter(from previousState: GKState?) {
        let earth = self.scene.childNode(withName: "Earth") as! PlanetNode
        earth.currentOwner = Owner.player
        earth.population = 40
        let uranus = self.scene.childNode(withName: "Uranus") as! PlanetNode
        uranus.currentOwner = Owner.enemy
        uranus.population = 40
        let texts = self.scene.childNode(withName: "TextLabels")!
        texts.run(SKAction.fadeIn(withDuration: 0.5))
        // Play music
        do {
            try self.scene.music = AVAudioPlayer(contentsOf: self.scene.soundTracks[0])
            self.scene.music.delegate = self.scene
            self.scene.music.prepareToPlay()
            self.scene.music.play()
        } catch {
            print("....")
        }
    }
//
//    override func willExit(to nextState: GKState) {
//        
//    }
    
    override func update(deltaTime seconds: TimeInterval) {
        for planet in self.scene.planets {
            planet.relatedEntity.update(deltaTime: seconds)
        }
        self.scene.player.update(deltaTime: seconds)
        self.scene.enemy.update(deltaTime: seconds)
    }
}
