//
//  QBeeSetUpQBee.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation

class QBeeSetUpQBee: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius=20;
    }
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func NextScreenButton(_ sender: Any) {
        self.performSegue(withIdentifier: "NextScreen0", sender: self)
    }
}
