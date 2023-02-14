import SpriteKit
import AVFoundation
class StartCard: Card {
    override func switchedOn() {
        do {
            let cardsScene = self.scene as! CardsScene
            if cardsScene.music != nil {
                cardsScene.music.stop()
            }
            try cardsScene.music = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Begin", withExtension: "m4a")!)
            cardsScene.music.numberOfLoops = -1
            cardsScene.music.prepareToPlay()
            cardsScene.music.volume = 0.2
            cardsScene.music.play(atTime: cardsScene.music.deviceCurrentTime + 2.0)
        } catch {
            print("...")
        }
    }
}
