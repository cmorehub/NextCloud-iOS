//
//  Ethernet1.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation

class Ethernet1: UIViewController {
    @IBOutlet weak var NextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "NextScreen1", sender: self)
    }
    
}
