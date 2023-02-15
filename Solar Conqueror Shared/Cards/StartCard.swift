import SpriteKit
import AVFoundation
class StartCard: Card {
    lazy var startButton: SKNode? = {
        if let node = self.childNode(withName: "start") {
            if let textNode = node as? SKLabelNode {
                textNode.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
                textNode.colorBlendFactor = 1.0
                return textNode
            }
            return node
        } else {
            return nil
        }
    }()
    
    lazy var easyButton: SKLabelNode? = {
        self.childNode(withName: "easy") as? SKLabelNode
    }()
    
    lazy var normalButton: SKLabelNode? = {
        self.childNode(withName: "normal") as? SKLabelNode
    }()

    lazy var hardButton: SKLabelNode? = {
        self.childNode(withName: "hard") as? SKLabelNode
    }()
    
    override var vibrantButtons: [SKNode] {
        return [self.nextButton!, self.startButton!]
    }
    
    override func mouseUpFromScene(nodes: [SKNode]) {
        super.mouseUpFromScene(nodes: nodes)
        if let nButton = self.startButton {
            if nodes.contains(nButton) {
                let cardScene = self.scene as! CardsScene
                cardScene.transitionToPlanetScene()
            }
        }
        if let easyButton {
            if nodes.contains(easyButton) {
                Preferences.difficulty = .easy
                onDifficultyChanged()
            }
        }
        if let normalButton {
            if nodes.contains(normalButton) {
                Preferences.difficulty = .normal
                onDifficultyChanged()
            }
        }
        if let hardButton {
            if nodes.contains(hardButton) {
                Preferences.difficulty = .hard
                onDifficultyChanged()
            }
        }
    }
    
    func onDifficultyChanged() {
        let difficulty = Preferences.difficulty
        switch difficulty {
        case .easy:
            easyButton?.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
            normalButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            hardButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .normal:
            easyButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            normalButton?.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
            hardButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .hard:
            easyButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            normalButton?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            hardButton?.color = #colorLiteral(red: 0.2, green: 0.7647058824, blue: 0.9098039216, alpha: 1)
        }
    }
    
    override func switchedOn() {
        easyButton?.colorBlendFactor = 1.0
        normalButton?.colorBlendFactor = 1.0
        hardButton?.colorBlendFactor = 1.0
        onDifficultyChanged()
        
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
