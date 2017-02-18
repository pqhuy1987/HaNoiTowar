//
//  StartScreenViewController.swift
//  Hanoi
//
//  Created by Matthew Irvine on 9/15/15.
//  Copyright © 2015 Matthew Irvine. All rights reserved.
//

import Foundation
import UIKit

class StartScreenViewController : UIViewController {
    static let GameSegueIdentifier = "SegueToGame"
    
    @IBOutlet weak var discSlider: UISlider!
    @IBOutlet weak var discNumberLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var numberOfDiscs = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discSlider.addTarget(self, action: #selector(StartScreenViewController.handleSliderChange), for: UIControlEvents.valueChanged)
        discSlider.value = Float(self.numberOfDiscs)
        handleSliderChange()
    }
    
    func handleSliderChange() {
        self.numberOfDiscs = Int(round(discSlider.value))
        discNumberLabel.text = "Number of Discs: \(self.numberOfDiscs)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StartScreenViewController.GameSegueIdentifier {
            let gvc = segue.destination as! GameViewController
            gvc.numberOfDiscs = self.numberOfDiscs
        }
    }
}
