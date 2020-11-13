//
//  PlanetsScene.swift
//  Solar Conqueror
//
//  Created by exgphe on 14/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import SpriteKit
import GameplayKit
import AVFoundation

public class PlanetsScene: InteractableScene, AVAudioPlayerDelegate {
    
    var lastUpdateTimeInterval: TimeInterval = 0 // For calculating deltaTime
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0
    
    var stateMachine: GKStateMachine!
    
    var currentPlaying = 0
    var soundTracks = [Bundle.main.url(forResource: "main1", withExtension: "mp3")!, Bundle.main.url(forResource: "main2", withExtension: "mp3")!]
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        (self.view as! GameView).resetCardsScene()
        //        print(self.childNode(withName: "background"))
        self.stateMachine = GKStateMachine(states: [
            StartState(scene: self),
            NormalState(scene: self),
            VictoryState(scene: self),
            FailState(scene: self),
            ])
        for child in self.children {
            if let planet = child as? PlanetNode {
                self.planets.append(planet)
                planet.population = 0
            }
        }
        
        // Calculate and store distances between planets
        let lastIndex = self.planets.endIndex
        for (index, planet) in self.planets.enumerated() {
            for anotherPlanet in self.planets[index + 1 ..< lastIndex] {
                let distance = sqrt(pow(planet.position.x - anotherPlanet.position.x, 2.0) + pow(planet.position.y - anotherPlanet.position.y, 2.0))
                planet.distanceTo[anotherPlanet] = distance
                anotherPlanet.distanceTo[planet] = distance
            }
        }
        
        // Create sunshine
        self.childNode(withName: "sunshine")?.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 2.5), SKAction.fadeAlpha(to: 1, duration: 2.5)])))
        self.childNode(withName: "sunshine/sunlight")?.run(SKAction.repeatForever(SKAction.sequence([SKAction.customAction(withDuration: 2.5, actionBlock: { (node, time) in
            let light = node as! SKLightNode
            light.lightColor = light.lightColor.withAlphaComponent(1.0 - time * 0.08)
        }), SKAction.customAction(withDuration: 2.5, actionBlock: { (node, time) in
            let light = node as! SKLightNode
            light.lightColor = light.lightColor.withAlphaComponent(0.8 + time * 0.08)
        })])))
        // Play main music
        // self.run(SKAction.repeatForever(SKAction.sequence([SKAction.playSoundFileNamed("main1", waitForCompletion: true), SKAction.playSoundFileNamed("main2", waitForCompletion: true)])), withKey: "music")
        
        self.stateMachine.enter(NormalState.self)
        //        let posterize = CIFilter(name: "CIColorPosterize", withInputParameters: ["inputLevels": 2.0])
        //        self.filter = posterize
        //        self.shouldEnableEffects = true
        // let textLabelEffect = self.childNode(withName: "TextLabels/TextEffects") as! SKEffectNode
        // textLabelEffect.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 10.0])
        //  textLabelEffect.shouldEnableEffects = true
        //self.run(SKAction.sequence([SKAction.wait(forDuration: 5.0), SKAction.run {
        //   self.stateMachine.enter(FailState.self)
        //    }]))
    }
    
    override public func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTimeInterval
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTimeInterval = currentTime
        self.stateMachine.update(deltaTime: deltaTime)
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.currentPlaying += 1
        let url = self.soundTracks[self.currentPlaying % self.soundTracks.count]
        do {
            try self.music = AVAudioPlayer(contentsOf: url)
            self.music.delegate = self
            self.music.prepareToPlay()
            self.music.play()
        } catch {
            print("...")
        }
    }
}
