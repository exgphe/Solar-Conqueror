import SpriteKit

class ReadyCard: Card {
    override func switchedOff() {
        self.delayTransitionToPlanetsScene()
    }
}
