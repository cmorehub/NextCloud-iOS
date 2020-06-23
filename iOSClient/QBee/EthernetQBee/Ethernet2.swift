//
//  Ethernet2.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation

class Ethernet2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "NextScreen02", sender: self)
    }
}
