//
//  GameViewController.swift
//  Hanoi
//
//  Created by Matthew Irvine on 9/15/15.
//  Copyright (c) 2015 Matthew Irvine. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    static let menuSegueIdentifier = "SegueToMenu"
    var numberOfDiscs = 4

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            scene.initializeDiscsForCount(self.numberOfDiscs)
            scene.viewController = self
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GameViewController.menuSegueIdentifier {
            let ssvc = segue.destination as! StartScreenViewController
            ssvc.numberOfDiscs = self.numberOfDiscs
        }
    }
}
