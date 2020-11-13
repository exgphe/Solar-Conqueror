//
//  ViewController.swift
//  Solar_Conqueror_Sources
//
//  Created by 왕소림 on 2020/8/13.
//  Copyright © 2020 Xiaolin Wang. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.start()
    }
}

