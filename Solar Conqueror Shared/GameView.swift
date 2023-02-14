//
//  GameView.swift
//  Solar Conqueror
//
//  Created by exgphe on 15/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import SpriteKit

public class GameView:SKView {
    
    lazy var planetScene: PlanetsScene = {
        return PlanetsScene(fileNamed: "Planets")!
    }()
    
    lazy var cardsScene: CardsScene = {
        return CardsScene(fileNamed: "Cards")!
    }()
    
    #if os(macOS)
    //To enable mousemove events
    var trackingArea : NSTrackingArea?

    override public func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        let options : NSTrackingArea.Options =
            [.activeWhenFirstResponder, .mouseMoved ]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                      owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    override public func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    #endif
    
    func goToPlanetsScene(background: SKNode) {
        background.removeFromParent()
        self.planetScene.addChild(background)
        //        background.zPosition = -20
        background.position = CGPoint.zero
        //        self.presentScene(self.planetScene, transition: SKTransition.crossFade(withDuration: 2.0))
        self.presentScene(self.planetScene)
    }
    
    func goToVictory(background: SKNode?) {
        if background != nil {
            background!.removeFromParent()
            self.cardsScene.addChild(background!)
        }
        //        background.zPosition = -20
        //        background.position = CGPoint.zero
        let screenShot = self.texture(from: self.planetScene)!
        self.cardsScene.showResult(screenShotTexture: screenShot, result: .victory)
        self.presentScene(self.cardsScene, transition: SKTransition.crossFade(withDuration: 0.5))
    }
    
    func goToFailure(background: SKNode?) {
        if background != nil {
            background!.removeFromParent()
            self.cardsScene.addChild(background!)
        }
        //        background.zPosition = -20
        //        background.position = CGPoint.zero
        let screenShot = self.texture(from: self.planetScene)!
        self.cardsScene.showResult(screenShotTexture: screenShot, result: .defeated)
        self.presentScene(self.cardsScene, transition: SKTransition.crossFade(withDuration: 0.5))
    }
    
    func resetCardsScene() {
        self.cardsScene = CardsScene(fileNamed: "Cards")!
    }
    
    func resetPlanetsScene() {
        self.planetScene = PlanetsScene(fileNamed: "Planets")!
    }
    
    public func start() {
        self.presentScene(self.cardsScene)
    }
}
