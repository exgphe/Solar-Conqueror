//
//  GameViewController.swift
//  Solar Conqueror macOS
//
//  Created by Xiaolin Wang on 14/02/2023.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    @IBOutlet var skView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.start()
    }

}

